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
    optionalString
    ;
  cfg = config.modules.post-archiver-viewer;
  pkg = pkgs.callPackage ../packages/post-archiver-viewer { };
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
        ExecStart =
          let
            publicCfg = cfg.publicConfig;
            futureCfg = cfg.futureConfig;
            resizeCfg = cfg.resizeConfig;
            baseCmd = "${pkg}/bin/post-archiver-viewer --port ${toString cfg.port} --resize-cache-size ${toString resizeCfg.cacheSize} --resize-filter-type ${resizeCfg.filterType} --resize-algorithm ${resizeCfg.algorithm}";
            resourceUrlArg = optionalString (
              publicCfg.resourceUrl != null
            ) " --resource-url ${publicCfg.resourceUrl}";
            imagesUrlArg = optionalString (publicCfg.imagesUrl != null) " --images-url ${publicCfg.imagesUrl}";
            fullTextSearchArg = if futureCfg.fullTextSearch then " --full-text-search true" else "";
          in
          baseCmd + resourceUrlArg + imagesUrlArg + fullTextSearchArg;
        User = "${toString cfg.uid}";
        Group = "${toString cfg.gid}";
      }
      // cfg.serviceConfig;
      environment = {
        ARCHIVER_PATH = cfg.archiver;
      };
    };

    environment.systemPackages = [
      pkg
    ];
  };
}
