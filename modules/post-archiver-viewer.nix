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
  cfg = config.modules.post-archiver-viewer;
  pkg = pkgs.callPackage ../packages/post-archiver-viewer {
    args = {
      inherit (cfg)
        archiver
        port
        publicConfig
        futureConfig
        resizeConfig
        ;
    };
  };
in
{
  options.modules.post-archiver-viewer = {
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
    archiver = mkOption {
      type = types.path;
    };
    port = mkOption {
      type = types.int;
      default = 3000;
    };
    publicConfig = {
      resourceUrl = mkOption {
        type = types.nullOr types.singleLineStr;
        default = null;
      };
      imagesUrl = mkOption {
        type = types.nullOr types.singleLineStr;
        default = null;
      };
    };
    futureConfig = {
      fullTextSearch = mkOption {
        type = types.bool;
        default = false;
      };
    };
    resizeConfig = {
      cacheSize = mkOption {
        type = types.int;
        default = 200;
      };
      filterType = mkOption {
        type = types.enum [
          "lanczos3"
          "gaussian"
          "catmull-rom"
          "hamming"
          "mitchell"
          "bilinear"
          "box"
        ];
        default = "lanczos3";
      };
      algorithm = mkOption {
        type = types.enum [
          "super-sampling8x"
          "super-sampling4x"
          "super-sampling2x"
          "convolution"
          "interpolation"
          "nearest"
        ];
        default = "interpolation";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    systemd.services.post-archiver-viewer = {
      description = "PostArchiverViewer";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkg}/bin/post-archiver-viewer";
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
