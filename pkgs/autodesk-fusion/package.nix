{
  lib,
  stdenvNoCC,
  fetchurl,
  copyDesktopItems,
  makeDesktopItem,
  writeShellApplication,
  wineWow64Packages,
  winetricks,
  coreutils,
  curl,
  findutils,
  gnused,
  samba,
  xdg-utils,
}:

let
  # Lolig4's fork carries the maintained Fusion-on-Wine fixes
  forkFile =
    path: hash:
    fetchurl {
      url = "https://codeberg.org/Lolig4/Autodesk-Fusion-360-on-Linux/raw/commit/7da442d6af5ac2619e5151475d2be54efe6170bc/files/setup/data/${path}";
      inherit hash;
    };

  # stock wine above 11.10 renders a black canvas, so keep this on the version the fork's patches target
  wine = wineWow64Packages.unstableFull.overrideAttrs (old: rec {
    version = "11.17";
    src = fetchurl {
      url = "https://dl.winehq.org/wine/source/11.x/wine-${version}.tar.xz";
      hash = "sha256-jnUuKbuikBrZ+RUTk0XG7mcYSwmdQlcE2RWXHKXAVfw=";
    };
    # order matters, these build on each other
    patches = (old.patches or [ ]) ++ [
      (forkFile "inventor-patches/regloadappkey-binary-hive.patch" "sha256-khHmBwBi4KmQM6IBTuzJdjVHaKe1IuHTwnDF0R1z/EI=")
      (forkFile "inventor-patches/msi-generate-transform.patch" "sha256-yWtlXX3o64T2kYNQr2YddIoB9njfW0plOvBf6CT+zTg=")
      (forkFile "inventor-patches/wintrust-wtd-choice-blob.patch" "sha256-t6ocrkYeQj9NwIMZKgPtniGmyABUsSaOWyao2XCS9y0=")
      (forkFile "inventor-patches/ole32-revokedragdrop-release-order.patch" "sha256-H1VdpDiXwK9t0DX0i+l/Fp/1p+uIJZac8zszRqT4VW0=")
      (forkFile "inventor-patches/services-session0-scm1053.patch" "sha256-IGhE2NRTaeCxDx7EOlKGKPrLMMYCsJhoED7zeNE43bw=")
      (forkFile "fusion-patches/winex11-owned-tool-windows.patch" "sha256-kGqkQG3Wy6dLWtKfC/oT+tIX44fXaEO31E6u4pMcTlo=")
      (forkFile "fusion-patches/dwrite-glyph-cache-rendering-mode.patch" "sha256-YbmWRbBOOvVu9rmJr3hOPVO1NiytZB2CIEpjgbgBrbo=")
      (forkFile "inventor-patches/ntdll-mapuserphysicalpagesscatter.patch" "sha256-Te5HVSG9y+q1p1XLnJIzRk5h9KxPseen/BYvN4RaEuY=")
      (forkFile "fusion-patches/win32u-vulkan-wait-for-present.patch" "sha256-HUqtv22eFETmVIsbPx6gfKXNiFm6EvVFMBxQRvDGZLo=")
      (forkFile "fusion-patches/symcrypt-rsa-exponent1.patch" "sha256-3Rwm+EMgTEDcVoQpZrucgYXaWWO1nuyFfoSjfOKDUoQ=")
    ];
  });

  launcher = writeShellApplication {
    name = "autodesk-fusion";
    runtimeInputs = [
      wine
      winetricks
      coreutils
      curl
      findutils
      gnused
      samba # ntlm_auth
      xdg-utils
    ];
    runtimeEnv = {
      FUSION_OPTIONS = forkFile "video_driver/DXVK/NMachineSpecificOptions.xml" "sha256-xyssZVZicb+GepcrnU+aMqTsJfsVmo2EBqUwu6TiyR8=";
      # bin/wine is a wrapper script, winetricks needs the real elf to detect wow64 and otherwise fails on every verb
      WINE_BIN = "${wine}/bin/.wine";
      WINESERVER_BIN = "${wine}/bin/wineserver";
    };
    text = builtins.readFile ./autodesk-fusion.sh;
  };

  icon = fetchurl {
    url = "https://codeberg.org/cryinkfly/Autodesk-Fusion-360-on-Linux/raw/commit/53b02038548f01a6e0a1fa2def0a9b545f1561c1/files/setup/resource/graphics/autodesk_fusion.svg";
    hash = "sha256-YSz+4mWksZbut/gv4dt7d6MjsKhqNgWU2rbO2KmixOw=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "autodesk-fusion";
  version = "0-unstable-2026-10-30";

  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = "autodesk-fusion";
      desktopName = "Autodesk Fusion";
      genericName = "CAD Application";
      exec = "autodesk-fusion";
      icon = "autodesk-fusion";
      categories = [
        "Graphics"
        "Engineering"
      ];
      startupWMClass = "fusion360.exe";
    })
    # browser sign-in redirects back through this
    (makeDesktopItem {
      name = "autodesk-fusion-identity";
      desktopName = "Autodesk Identity URL Handler";
      exec = "autodesk-fusion %u";
      noDisplay = true;
      startupNotify = false;
      mimeTypes = [ "x-scheme-handler/adskidmgr" ];
    })
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 ${lib.getExe launcher} $out/bin/autodesk-fusion
    install -Dm644 ${icon} $out/share/icons/hicolor/scalable/apps/autodesk-fusion.svg
    runHook postInstall
  '';

  passthru = { inherit wine; };

  meta = {
    description = "Autodesk Fusion CAD/CAM on a patched Wine, installed into a user prefix on first run";
    homepage = "https://www.autodesk.com/products/fusion-360";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "autodesk-fusion";
  };
}
