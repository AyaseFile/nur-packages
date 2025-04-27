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
  cfg = config.programs.patreon-archive;
  pkg = pkgs.callPackage ../packages/patreon-archive { };
in
{
  options.programs.patreon-archive = {
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
    systemd.services.patreon-archive = {
      description = "PatreonArchive";
      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkg}/bin/patreon-archive ${cfg.extraArgs}";
        User = "1000";
        Group = "100";
      };
      environment = {
        SESSION = cfg.session;
        OUTPUT = cfg.output;
      };
    };

    systemd.timers.patreon-archive = {
      description = "PatreonArchive timer";
      wantedBy = [ "timers.target" ];
      wants = [ "patreon-archive.service" ];
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
