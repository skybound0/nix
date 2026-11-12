# fusion updates itself in place, so the app lives in a mutable prefix and not the nix store

root="${XDG_DATA_HOME:-$HOME/.local/share}/autodesk-fusion"
downloads="$root/downloads"
state="$root/state"
logs="$root/logs"

export WINEPREFIX="$root/prefix"
installers="$WINEPREFIX/drive_c/users/$USER/Downloads"
export WINEDEBUG="${WINEDEBUG:--all,+err}"
export DXVK_LOG_LEVEL=none
# keep wine from writing its own menu entries and file associations into the home directory
export WINEDLLOVERRIDES="winemenubuilder.exe=d"

# newest match wins, old builds stay behind in webdeploy/production after an update
newest() {
    find "$WINEPREFIX/drive_c" -name "$1" -printf '%T@ %p\n' | sort -rn | sed -n '1s/^[^ ]* //p'
}

fetch() {
    [[ -e "$downloads/$1" ]] && return
    curl --fail --location --retry 3 --continue-at - --output "$downloads/$1.part" "$2"
    mv "$downloads/$1.part" "$downloads/$1"
}

# each step is recorded so an interrupted install picks up where it stopped
step() {
    local name="$1"
    shift
    [[ -e "$state/$name" ]] && return
    echo "==> $name"
    "$@"
    touch "$state/$name"
}

download_installers() {
    # both urls are unversioned and change without notice, which is why they can't be fetched at build time
    fetch FusionClientInstaller.exe "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe"
    fetch MicrosoftEdgeWebView2RuntimeInstallerX64.exe "https://go.microsoft.com/fwlink/?linkid=2124701"
}

init_prefix() {
    wineboot --init
    wineserver -w
    winetricks -q sandbox
    # the sandbox verb removes the Z: drive, so the installers have to be reachable from inside the prefix
    rm -rf "$installers"
    ln -s "$downloads" "$installers"
}

install_runtimes() {
    winetricks -q gdiplus arial verdana dotnet48 fontsmooth=rgb winhttp
    # winetricks can reset the windows version while installing the above
    winetricks -q win11
    winetricks -q dxvk vkd3d
    # wine's hlsl compiler can't translate the shaders Fusion Electronics uses
    winetricks -q d3dcompiler_47
}

configure_prefix() {
    # stop metrics reporting
    wine reg add 'HKCU\Software\Wine\DllOverrides' /v adpclientservice.exe /t REG_SZ /d native /f
    # the navigation bar only works with wine's builtin dx9
    wine reg add 'HKCU\Software\Wine\DllOverrides' /v AdCefWebBrowser.exe /t REG_SZ /d builtin /f
    # wine's msvcp140 lacks std::get_new_handler, which aborts Fusion on startup
    wine reg add 'HKCU\Software\Wine\DllOverrides' /v msvcp140 /t REG_SZ /d native,builtin /f
    wine reg add 'HKCU\Software\Wine\DllOverrides' /v bcp47langs /t REG_SZ /d '' /f
    wine reg add 'HKCU\Software\Wine\X11 Driver' /v Managed /t REG_SZ /d Y /f
    wine reg add 'HKCU\Software\Wine\X11 Driver' /v Decorated /t REG_SZ /d Y /f
}

# these modules switch to a linux-host ipc mode when they see wine_get_version, and fusion drawings
# then waits forever on fifos under Z:\tmp that nothing creates, so hide wine from them
hide_wine_exports() {
    wine reg add 'HKCU\Software\Wine\HideWineExports' /v AcIpc_2_x64.dll /t REG_SZ /d '' /f
    wine reg add 'HKCU\Software\Wine\HideWineExports' /v AcFusionService.crx /t REG_SZ /d '' /f
}

# fusion is dpi aware but the drawing engine it embeds is not, so under scaling wine maps the engine's
# input and drawing at a different dpi than its host window and clicks land offset from the cursor.
# wine matches this key on the bare exe name, so it survives fusion updates moving the build directory
drawings_dpi_aware() {
    wine reg add 'HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' /v accoreconsole.exe /t REG_SZ /d '~ HIGHDPIAWARE' /f
}

install_webview2() {
    # the exit code is unreliable, it can report an error after a good install
    wine "$installers/MicrosoftEdgeWebView2RuntimeInstallerX64.exe" /silent /install || true
    # the edge updater can linger in the background
    timeout 5m wineserver -w || true
    [[ -n "$(newest msedgewebview2.exe)" ]]
}

install_fusion() {
    # the installer never exits by itself and a second pass finalizes it, so the timeouts are part of the process
    timeout -k 30s 9m wine "$installers/FusionClientInstaller.exe" --quiet || true
    sleep 2
    timeout -k 30s 2m wine "$installers/FusionClientInstaller.exe" --quiet || true
    [[ -n "$(newest Fusion360.exe)" ]]
}

write_options() {
    local users="$WINEPREFIX/drive_c/users/$USER"
    local dir
    for dir in \
        "$users/AppData/Roaming/Autodesk/Neutron Platform/Options" \
        "$users/AppData/Local/Autodesk/Neutron Platform/Options" \
        "$users/Application Data/Autodesk/Neutron Platform/Options"; do
        install -Dm644 "$FUSION_OPTIONS" "$dir/NMachineSpecificOptions.xml"
    done
}

register_sign_in() {
    xdg-mime default autodesk-fusion-identity.desktop x-scheme-handler/adskidmgr
}

# fusion looks for this one level above ADPCER/, and every update unpacks a new build that needs it
link_device_settings_provider() {
    local dll
    find "$WINEPREFIX/drive_c/Program Files/Autodesk/webdeploy/production" \
        -path '*/ADPCER/DeviceSettingsProvider.dll' -print0 |
        while IFS= read -r -d '' dll; do
            ln -sf "$dll" "$(dirname "$(dirname "$dll")")/DeviceSettingsProvider.dll"
        done
}

case "${1:-}" in
adskidmgr:*)
    exec wine "$(newest AdskIdentityManager.exe)" "$1"
    ;;
esac

mkdir -p "$downloads" "$state" "$logs"

# not a pipeline, the edge updater keeps the log pipe open after install and tee would never exit
exec 3>&1 4>&2 > >(tee -a "$logs/install.log") 2>&1
step download_installers download_installers
step init_prefix init_prefix
step install_runtimes install_runtimes
step configure_prefix configure_prefix
step hide_wine_exports hide_wine_exports
step drawings_dpi_aware drawings_dpi_aware
step install_webview2 install_webview2
step install_fusion install_fusion
step write_options write_options
step register_sign_in register_sign_in
exec 1>&3 2>&4 3>&- 4>&-

link_device_settings_provider

trap 'wineserver -k' INT TERM
QTWEBENGINE_DISABLE_SANDBOX=1 wine "$(newest Fusion360.exe)" &
wait $! || true
wineserver -k || true
