{
  pkgs,
  ...
}:

{
  services.xserver.enable = true;
  services.xserver.excludePackages = with pkgs; [ xterm ];
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-apps.enable = false;
  services.desktopManager.gnome.sessionPath = [ pkgs.gdm ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
  ];

  catppuccin = {
    enable = true;
    autoEnable = true;
  };

  # opencl for darktable etc
  hardware.amdgpu.opencl.enable = true;

  environment.systemPackages = with pkgs; [
    # gnome core apps
    gnome-console
    nautilus
    gnome-calculator
    gnome-calendar
    gnome-system-monitor
    gnome-disk-utility
    gnome-logs
    loupe
    papers
    showtime
    snapshot
    baobab

    # polkit only reads actions from the system profile (i think)
    bitwarden-desktop
  ];
}
