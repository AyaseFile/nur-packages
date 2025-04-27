{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    mkIf
    types
    ;
  cfg = config.programs.fanbox-archive;
  pkg = pkgs.callPackage ../packages/fanbox-archive { };
in
{
  options.programs.fanbox-archive = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    session = mkOption {
      type = types.singleLineStr;
    };
    output = mkOption {
      type = types.path;
    };
    extraArgs = mkOption {
      type = types.singleLineStr;
      default = "";
    };
    interval = mkOption {
      type = types.singleLineStr;
      default = "14d";
      example = "1d";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.fanbox-archive = {
      description = "FanboxArchive";
      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkg}/bin/fanbox-archive ${cfg.extraArgs}";
        User = "1000";
        Group = "100";
      };
      environment = {
        FANBOXSESSID = cfg.session;
        OUTPUT = cfg.output;
      };
    };

    systemd.timers.fanbox-archive = {
      description = "FanboxArchive timer";
      wantedBy = [ "timers.target" ];
      wants = [ "fanbox-archive.service" ];
      timerConfig = {
        OnUnitActiveSec = cfg.interval;
        AccuracySec = "1h";
        Persistent = true;
      };
    };

    environment.systemPackages = [
      pkg
    ];
  };
}
