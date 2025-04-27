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
  cfg = config.programs.post-archiver-viewer;
  pkg = pkgs.callPackage ../packages/post-archiver-viewer { };
in
{
  options.programs.post-archiver-viewer = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    archiver = mkOption {
      type = types.path;
    };
    resourceUrl = mkOption {
      type = types.nullOr types.singleLineStr;
      default = null;
    };
    imagesUrl = mkOption {
      type = types.nullOr types.singleLineStr;
      default = null;
    };
    port = mkOption {
      type = types.int;
      default = 3000;
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
            baseCmd = "${pkg}/bin/post-archiver-viewer --port ${toString cfg.port} --resize-cache-size ${toString cfg.resizeConfig.cacheSize} --resize-filter-type ${cfg.resizeConfig.filterType} --resize-algorithm ${cfg.resizeConfig.algorithm}";
            resourceUrlArg = lib.optionalString (cfg.resourceUrl != null) " --resource-url ${cfg.resourceUrl}";
            imagesUrlArg = lib.optionalString (cfg.imagesUrl != null) " --images-url ${cfg.imagesUrl}";
          in
          baseCmd + resourceUrlArg + imagesUrlArg;
        User = "1000";
        Group = "100";
      };
      environment = {
        ARCHIVER_PATH = cfg.archiver;
      };
    };

    environment.systemPackages = [
      pkg
    ];
  };
}
