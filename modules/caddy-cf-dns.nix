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
  cfg = config.modules.caddy-cf-dns;
in
{
  options.modules.caddy-cf-dns = {
    enable = mkEnableOption "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS, with `dns.providers.cloudflare` plugin support";

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
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
        hash = "sha256-saKJatiBZ4775IV2C5JLOmZ4BwHKFtRZan94aS5pO90=";
      };
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
