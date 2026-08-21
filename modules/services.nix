{ pkgs, ... }:

{
  services.openssh.enable = true;

  services.fwupd.enable = true;

  services.fprintd.enable = true;

  # cups. hide cups.desktop
  services.printing = {
    enable = true;
    package = pkgs.cups.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        rm -f $out/share/applications/cups.desktop
      '';
    });
  };

  # gsconnect. extension dconf in hosts/../graphical.nix, ports in hosts/../networking.nix
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  # openterfaceQT
  services.openterface = {
    enable = true;
  };
  users.users.skybound.extraGroups = [ "dialout" "video" ];
  services.udev.packages = [
    (pkgs.writeTextDir "lib/udev/rules.d/70-openterface.rules" ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="534d", ATTRS{idProduct}=="2109", TAG+="uaccess"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="534d", ATTRS{idProduct}=="2109", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="345f", ATTRS{idProduct}=="2109", TAG+="uaccess"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="345f", ATTRS{idProduct}=="2109", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="345f", ATTRS{idProduct}=="2132", TAG+="uaccess"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="345f", ATTRS{idProduct}=="2132", TAG+="uaccess"
      SUBSYSTEM=="ttyUSB", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"
      SUBSYSTEM=="ttyACM", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="fe0c", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="fe0c", TAG+="uaccess"
    '')
  ];
}
