{ stdenvNoCC }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gnome-shell-extension-lockscreen-fingerprint";
  version = "1";

  src = ./src;

  installPhase = ''
    runHook preInstall
    dir=$out/share/gnome-shell/extensions/${finalAttrs.passthru.extensionUuid}
    mkdir -p $dir
    cp metadata.json extension.js $dir/
    runHook postInstall
  '';

  passthru.extensionUuid = "lockscreen-fingerprint@skybound";
})
