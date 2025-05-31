{ pkgs, ... }:

let
  btop-darwin = pkgs.callPackage ../packages/btop-darwin { };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      btop = if prev.stdenv.isDarwin then btop-darwin else prev.btop;
    })
  ];
}
