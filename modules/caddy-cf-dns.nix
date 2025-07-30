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
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
        hash = "sha256-S1JN7brvH2KIu7DaDOH1zij3j8hWLLc0HdnUc+L89uU=";
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
