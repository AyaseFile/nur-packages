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
    optionalAttrs
    ;
  cfg = config.programs.eh-archive;
  pkg = pkgs.callPackage ../packages/eh-archive { };
in
{
  options.programs.eh-archive = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    site = mkOption {
      type = types.enum [
        "e-hentai.org"
        "exhentai.org"
      ];
      default = "e-hentai.org";
    };
    memberId = mkOption {
      type = types.singleLineStr;
    };
    passHash = mkOption {
      type = types.singleLineStr;
    };
    igneous = mkOption {
      type = types.nullOr types.singleLineStr;
      default = null;
    };
    port = mkOption {
      type = types.int;
      default = 3000;
    };
    archiveOutput = mkOption {
      type = types.path;
    };
    libraryRoot = mkOption {
      type = types.path;
    };
    tagDbRoot = mkOption {
      type = types.path;
    };
    limit = mkOption {
      type = types.int;
      default = 5;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    systemd.services.eh-archive = {
      description = "EhArchive";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkg}/bin/eh-archive --port ${toString cfg.port} --archive-output ${cfg.archiveOutput} --library-root ${cfg.libraryRoot} --tag-db-root ${cfg.tagDbRoot} --limit ${toString cfg.limit}";
        User = "1000";
        Group = "100";
      };
      environment =
        {
          EH_SITE = cfg.site;
          EH_AUTH_ID = cfg.memberId;
          EH_AUTH_HASH = cfg.passHash;
        }
        // optionalAttrs (cfg.igneous != null) {
          EH_AUTH_IGNEOUS = cfg.igneous;
        };
    };

    environment.systemPackages = [
      pkg
    ];
  };
}
