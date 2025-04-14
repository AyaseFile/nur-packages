{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  cfg = config.services.fanbox-archive;
  pkg = pkgs.callPackage ../packages/fanbox-archive { };
in
{
  options.services.fanbox-archive = {
    enable = mkEnableOption "FanboxArchive";
    user = mkOption {
      type = types.str;
      description = "User under which the service runs";
    };
    group = mkOption {
      type = types.str;
      description = "Group under which the service runs";
    };
    sessid = mkOption {
      type = types.str;
      description = "Your `FANBOXSESSID` cookie";
    };
    output = mkOption {
      type = types.path;
      description = "Which path you want to save";
    };
    interval = mkOption {
      type = types.str;
      default = "14d";
      example = "1d";
      description = "How often to run the sync (systemd time format)";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.fanbox-archive = {
      description = "FanboxArchive";
      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkg}/bin/fanbox-archive";
        User = cfg.user;
        Group = cfg.group;
        StandardOutput = "journal";
        StandardError = "journal";
      };
      environment = {
        FANBOXSESSID = cfg.sessid;
        OUTPUT = cfg.output;
      };
    };

    systemd.timers.fanbox-archive = {
      description = "Timer for FanboxArchive";
      wantedBy = [ "timers.target" ];
      wants = [ "fanbox-archive.service" ];
      timerConfig = {
        OnUnitActiveSec = cfg.interval;
        AccuracySec = "1h";
        Persistent = true;
      };
    };
  };
}
