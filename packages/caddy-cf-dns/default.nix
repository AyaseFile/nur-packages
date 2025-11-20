{
  pkgs,
  caddy ? pkgs.caddy,
}:

caddy.withPlugins {
  plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
  hash = "sha256-aRMg7R0dBAy+LJeGCMPg6HKppM6NPX2NPwtc0CeSQLg=";
}
