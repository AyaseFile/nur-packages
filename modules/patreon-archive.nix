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
    mkMerge
    ;
  cfg = config.modules.patreon-archive;
  pkg = pkgs.callPackage ../packages/patreon-archive {
    args = {
      inherit (cfg) session output extraArgs;
    };
  };
in
{
  options.modules.patreon-archive = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    uid = mkOption {
      type = types.int;
    };
    gid = mkOption {
      type = types.int;
    };
    serviceConfig = mkOption {
      type = types.attrsOf types.str;
      default = { };
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
    timer = mkOption {
      type = types.bool;
      default = true;
    };
    interval = mkOption {
      type = types.singleLineStr;
      default = "14d";
      example = "1d";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      systemd.services.patreon-archive = {
        description = "PatreonArchive";
        serviceConfig = {
          Type = "exec";
          ExecStart = "${pkg}/bin/patreon-archive";
          User = "${toString cfg.uid}";
          Group = "${toString cfg.gid}";
        }
        // cfg.serviceConfig;
      };

      environment.systemPackages = [
        pkg
      ];
    })
    (mkIf cfg.timer {
      systemd.timers.patreon-archive = {
        description = "PatreonArchive timer";
        wantedBy = [ "timers.target" ];
        wants = [ "patreon-archive.service" ];
        timerConfig = {
          OnUnitActiveSec = cfg.interval;
          Persistent = true;
        };
      };
    })
  ];
}
