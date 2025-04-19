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
  cfg = config.programs.fanbox-archive;
  pkg = pkgs.callPackage ../packages/fanbox-archive { };
in
{
  options.programs.fanbox-archive = {
    enable = mkEnableOption "FanboxArchive";
    session = mkOption {
      type = types.singleLineStr;
      description = "Your `FANBOXSESSID` cookie";
    };
    output = mkOption {
      type = types.path;
      description = "Which path you want to save";
    };
    extraArgs = mkOption {
      type = types.singleLineStr;
      default = "";
      description = "Extra arguments to pass";
    };
    interval = mkOption {
      type = types.singleLineStr;
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
      description = "Timer for FanboxArchive";
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
