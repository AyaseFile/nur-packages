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
  cfg = config.services.post-archiver-viewer;
  pkg = pkgs.callPackage ../packages/post-archiver-viewer { };
in
{
  options.services.post-archiver-viewer = {
    enable = mkEnableOption "PostArchiverViewer";
    user = mkOption {
      type = types.str;
      description = "User under which the service runs";
    };
    group = mkOption {
      type = types.str;
      description = "Group under which the service runs";
    };
    archiver = mkOption {
      type = types.path;
      description = "Path to the archiver library";
    };
    resourceUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "URL to the resource (optional)";
    };
    imagesUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "URL to the images (optional)";
    };
    port = mkOption {
      type = types.int;
      default = 3000;
      description = "Port to run the server on";
    };
    resizeConfig = {
      cacheSize = mkOption {
        type = types.int;
        default = 200;
        description = "The maximum cache size by number of images";
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
        description = "The filter type to use for resizing";
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
        description = "The algorithm to use for resizing";
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
        User = cfg.user;
        Group = cfg.group;
        StandardOutput = "journal";
        StandardError = "journal";
      };
      environment = {
        ARCHIVER_PATH = cfg.archiver;
      };
    };
  };
}
