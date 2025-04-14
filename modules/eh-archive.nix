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
    optionalAttrs
    ;
  cfg = config.services.eh-archive;
  pkg = pkgs.callPackage ../packages/eh-archive { };
in
{
  options.services.eh-archive = {
    enable = mkEnableOption "EhArchive";
    user = mkOption {
      type = types.str;
      description = "User under which the service runs";
    };
    group = mkOption {
      type = types.str;
      description = "Group under which the service runs";
    };
    site = mkOption {
      type = types.enum [
        "e-hentai.org"
        "exhentai.org"
      ];
      default = "e-hentai.org";
      description = "The site you want to retrieve from";
    };
    memberId = mkOption {
      type = types.str;
      description = "Your `ipb_member_id` cookie";
    };
    passHash = mkOption {
      type = types.str;
      description = "Your `ipb_pass_hash` cookie";
    };
    igneous = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Your `igneous` cookie";
    };
    port = mkOption {
      type = types.int;
      default = 3000;
      description = "Port to run the server on";
    };
    archiveOutput = mkOption {
      type = types.path;
      description = "Which path you want to save the archive to";
    };
    libraryRoot = mkOption {
      type = types.path;
      description = "Path to the calibre library root";
    };
    tagDbRoot = mkOption {
      type = types.path;
      description = "Path to the tag database root";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    systemd.services.eh-archive = {
      description = "EhArchive";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkg}/bin/eh-archive --port ${toString cfg.port} --archive-output ${cfg.archiveOutput} --library-root ${cfg.libraryRoot} --tag-db-root ${cfg.tagDbRoot}";
        User = cfg.user;
        Group = cfg.group;
        StandardOutput = "journal";
        StandardError = "journal";
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
  };
}
