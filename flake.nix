{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      inherit (builtins) elem filter;
      inherit (nixpkgs.lib) genAttrs replaceStrings;
      inherit (nixpkgs.lib.filesystem) listFilesRecursive;

      nameOf = path: replaceStrings [ ".nix" ] [ "" ] (baseNameOf (toString path));

      moduleFiles = listFilesRecursive ./modules;
      modules = map nameOf moduleFiles;

      specialModules = [ ];

      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;

      loadPackages =
        { callPackage, directory }:
        let
          subdirs = builtins.attrNames (builtins.readDir directory);
          packages = builtins.listToAttrs (
            map (name: {
              inherit name;
              value = callPackage (directory + "/${name}") { };
            }) subdirs
          );
        in
        packages;

      overlayFiles = listFilesRecursive ./overlays;
      overlays = map nameOf overlayFiles;
    in
    {
      legacyPackages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        loadPackages {
          inherit (pkgs) callPackage;
          directory = ./packages;
        }
      );
      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );
      modules = (
        genAttrs (filter (name: !(elem name specialModules)) modules) (name: import ./modules/${name}.nix)
        // { }
      );
      overlays = (genAttrs overlays (name: import ./overlays/${name}.nix));
    };
}
