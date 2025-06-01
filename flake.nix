{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      inherit (builtins)
        attrNames
        elem
        filter
        listToAttrs
        readDir
        ;
      inherit (nixpkgs) lib;
      inherit (lib)
        filterAttrs
        genAttrs
        isDerivation
        replaceStrings
        ;
      inherit (lib.filesystem) listFilesRecursive;
      inherit (lib.systems) flakeExposed;

      nameOf = path: replaceStrings [ ".nix" ] [ "" ] (baseNameOf (toString path));

      moduleFiles = listFilesRecursive ./modules;
      modules = map nameOf moduleFiles;

      specialModules = [ ];

      forAllSystems = genAttrs flakeExposed;

      loadPackages =
        { callPackage, directory }:
        let
          subdirs = attrNames (readDir directory);
          packages = listToAttrs (
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
      packages = forAllSystems (system: filterAttrs (_: v: isDerivation v) self.legacyPackages.${system});
      modules = (
        genAttrs (filter (name: !(elem name specialModules)) modules) (name: import ./modules/${name}.nix)
        // { }
      );
      overlays = (genAttrs overlays (name: import ./overlays/${name}.nix));
    };
}
