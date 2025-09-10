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
  cfg = config.modules.fanbox-archive;
  pkg = pkgs.callPackage ../packages/fanbox-archive {
    args = {
      inherit (cfg)
        session
        output
        userAgent
        cookies
        extraArgs
        ;
    };
  };
in
{
  options.modules.fanbox-archive = {
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
    userAgent = mkOption {
      type = types.nullOr types.singleLineStr;
      default = null;
    };
    cookies = mkOption {
      type = types.nullOr types.singleLineStr;
      default = null;
      example = "name=value; name2=value2; ...";
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
      systemd.services.fanbox-archive = {
        description = "FanboxArchive";
        serviceConfig = {
          Type = "exec";
          ExecStart = "${pkg}/bin/fanbox-archive";
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
      systemd.timers.fanbox-archive = {
        description = "FanboxArchive timer";
        wantedBy = [ "timers.target" ];
        wants = [ "fanbox-archive.service" ];
        timerConfig = {
          OnUnitActiveSec = cfg.interval;
          Persistent = true;
        };
      };
    })
  ];
}
