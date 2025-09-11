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

  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "xiao-e-yun";
    repo = "PostArchiverViewer";
    rev = "v${version}";
    sha256 = "sha256-3BqOAIF0Xcu5bO/ZepPuqfauKnM2hXO0oafHuqP7aLw=";
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

    outputHash = "sha256-zU9PxI6SmdLMmYgqfZb3IqI49SsRF0AlRDodrywqQic=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  unwrapped = rustPlatform.buildRustPackage {
    pname = "PostArchiverViewer-unwrapped";
    inherit version src;

    cargoHash = "sha256-v47DqG3zzKaCK6fnNshDYC2/RnMHlQOt0cnXLQiNqzw=";

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
        --add-flags "--resize-cache-size ${toString args.resizeConfig.cacheSize}" \
        --add-flags "--resize-filter-type ${args.resizeConfig.filterType}" \
        --add-flags "--resize-algorithm ${args.resizeConfig.algorithm}" \
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
