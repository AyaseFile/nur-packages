{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  bun,
  nodejs,
  stdenv,
  makeWrapper,
  args ? { },
}:

let
  inherit (lib) optionalString;

  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "xiao-e-yun";
    repo = "PostArchiverViewer";
    rev = "v${version}";
    sha256 = "sha256-gaksKefv0mjt8aBrziB7lgNdUbYXayfVW/N/QzYqpLY=";
  };

  frontendDeps = stdenv.mkDerivation {
    pname = "PostArchiverViewer-frontend-deps";
    inherit version src;

    nativeBuildInputs = [ bun ];

    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      export HOME=$(mktemp -d)
      cd frontend
      rm -rf .husky
      bun install --frozen-lockfile --no-cache --ignore-scripts
      mkdir -p $out
      cp -r node_modules $out/
      cp bun.lockb package.json $out/
    '';

    outputHash = "sha256-ih1ueUHNzrdS23DAP76EHnypxtrrF9DV+tXpfqEPrOA=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  unwrapped = rustPlatform.buildRustPackage {
    pname = "PostArchiverViewer-unwrapped";
    inherit version src;

    cargoHash = "sha256-Frh+HxY29NooctCxBwHCJJuuhhBYNY+yrWyqkmx6ypo=";

    cargoPatches = [
      ./Cargo.lock.patch
    ];

    env.RUSTC_BOOTSTRAP = 1;
    cargoBuildFlags = [ "--all-features" ];

    nativeBuildInputs = [
      pkg-config
      nodejs
    ];
    buildInputs = [
      openssl
    ];

    configurePhase = ''
      runHook preConfigure

      cd frontend
      export HOME=$(mktemp -d)
      cp -r ${frontendDeps}/node_modules .
      node node_modules/.bin/vite build
      cd ..

      runHook postConfigure
    '';

    postPatch = ''
      sed -i 's/^version = ".*"/version = "${version}"/' Cargo.toml
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      $out/bin/post-archiver-viewer -h > /dev/null
    '';

    passthru = {
      inherit frontendDeps;
    };
  };
in
stdenv.mkDerivation {
  pname = "PostArchiverViewer";
  version = unwrapped.version;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${unwrapped}/bin/post-archiver-viewer $out/bin/post-archiver-viewer \
      ${optionalString (args != { }) ''
        --add-flags "--port ${toString args.port}" \
        --add-flags "--resize-images-cache-size ${toString args.resizeConfig.cacheSize}" \
        --add-flags "--resize-images-filter-type ${args.resizeConfig.filterType}" \
        --add-flags "--resize-images-algorithm ${args.resizeConfig.algorithm}" \
        ${
          optionalString (
            args ? "publicConfig" && args.publicConfig ? "resourceUrl" && args.publicConfig.resourceUrl != null
          ) ''--add-flags "--resource-url ${args.publicConfig.resourceUrl}"''
        } \
        ${
          optionalString (
            args ? "publicConfig" && args.publicConfig ? "imagesUrl" && args.publicConfig.imagesUrl != null
          ) ''--add-flags "--images-url ${args.publicConfig.imagesUrl}"''
        } \
        ${
          optionalString (
            args ? "futureConfig" && args.futureConfig.fullTextSearch
          ) ''--add-flags "--full-text-search true"''
        } \
        --set ARCHIVER_PATH "${args.archiver}"
      ''}
  '';

  meta = with lib; {
    homepage = "https://github.com/xiao-e-yun/PostArchiverViewer";
    license = licenses.bsd3;
    maintainers = with maintainers; [ AyaseFile ];
    mainProgram = "post-archiver-viewer";
  };
}
