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
  cfg = config.programs.patreon-archive;
  pkg = pkgs.callPackage ../packages/patreon-archive { };
in
{
  options.programs.patreon-archive = {
    enable = mkEnableOption "PatreonArchive";
    session = mkOption {
      type = types.singleLineStr;
      description = "Your `session_id` cookie";
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
      description = "Timer for PatreonArchive";
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
