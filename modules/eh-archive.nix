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
  cfg = config.modules.eh-archive;
  pkg = pkgs.callPackage ../packages/eh-archive {
    args = {
      inherit (cfg)
        port
        archiveOutput
        libraryRoot
        tagDbRoot
        limit
        site
        memberId
        passHash
        igneous
        ;
    };
  };
in
{
  options.modules.eh-archive = {
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
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkg}/bin/eh-archive";
        User = "${toString cfg.uid}";
        Group = "${toString cfg.gid}";
      }
      // cfg.serviceConfig;
    };

    environment.systemPackages = [
      pkg
    ];
  };
}
