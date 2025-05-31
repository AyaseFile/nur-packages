{ pkgs, ... }:

let
  btop = pkgs.btop;
  btop-darwin = pkgs.callPackage ../packages/btop-darwin { };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      btop = if pkgs.stdenv.isDarwin then btop-darwin else btop;
    })
  ];
}
