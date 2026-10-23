{ pkgs, ... }:

{
  # secrets in modules/nextcloud.nix
  systemd.user.services.nextcloud-autosync = {
    Unit.Description = "Nextcloud Autosync";
    Service = {
      Type = "oneshot";
      EnvironmentFile = "/run/agenix/nextcloud-autosync";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/cloud";
      ExecStart = "${pkgs.nextcloud-client}/bin/nextcloudcmd -h --non-interactive %h/cloud https://thegoose.cloud";
      TimeoutStopSec = "180";
      KillSignal = "SIGINT";
    };
  };
  systemd.user.timers.nextcloud-autosync = {
    Unit.Description = "Run Nextcloud Autosync every 10min";
    Timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "10min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
