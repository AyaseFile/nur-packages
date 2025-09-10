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
  cfg = config.modules.caddy-cf-dns;
in
{
  options.modules.caddy-cf-dns = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    globalConfig = mkOption {
      type = types.str;
      default = "";
    };
    virtualHosts = mkOption {
      type = types.attrsOf types.anything;
      default = { };
    };
    envFile = mkOption {
      type = types.path;
      default = "/etc/caddy/.env";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    services.caddy = {
      enable = true;
      package = pkgs.callPackage ../packages/caddy-cf-dns { };
      globalConfig = cfg.globalConfig;
      virtualHosts = cfg.virtualHosts;
    };

    systemd.services.caddy = {
      serviceConfig = {
        EnvironmentFile = cfg.envFile;
      };
    };
  };
}
