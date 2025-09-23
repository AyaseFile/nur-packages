{
  pkgs,
  caddy ? pkgs.caddy,
}:

caddy.withPlugins {
  plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
  hash = "sha256-j+xUy8OAjEo+bdMOkQ1kVqDnEkzKGTBIbMDVL7YDwDY=";
}
