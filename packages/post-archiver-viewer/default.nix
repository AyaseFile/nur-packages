{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  fixup-yarn-lock,
  rustPlatform,
  pkg-config,
  openssl,
  yarn,
  nodejs,
}:

rustPlatform.buildRustPackage rec {
  pname = "PostArchiverViewer";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "xiao-e-yun";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-cDfuBGgpt8XZAf7SxWNLeK1kvuet+aGjQFGuaAQXDZI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-LnFK5oeG173f6EsEhZj4xVaPWDBiYrAhUVmvpldpIYg=";

  offlineCache = fetchYarnDeps {
    yarnLock = yarnLock;
    sha256 = "sha256-KD1/wQcAFb9abMkyh82+awe8Ol/d9q9W7XYK2SSik74=";
  };

  env.RUSTC_BOOTSTRAP = 1;
  cargoBuildFlags = [ "--all-features" ];

  nativeBuildInputs = [
    pkg-config
    yarn
    fixup-yarn-lock
    nodejs
  ];
  buildInputs = [
    openssl
  ];

  yarnLock = ./yarn.lock;

  postPatch = ''
    cp ${yarnLock} frontend/yarn.lock
  '';

  configurePhase = ''
    runHook preConfigure

    cd frontend
    export HOME=$(mktemp -d)
    yarn config --offline set yarn-offline-mirror ${offlineCache}
    chmod +w yarn.lock
    fixup-yarn-lock yarn.lock
    chmod -w yarn.lock
    rm -r .husky
    yarn install --frozen-lockfile --offline --no-progress --non-interactive --ignore-scripts
    node node_modules/.bin/vite build
    cd ..

    runHook postConfigure
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/post-archiver-viewer -h > /dev/null
  '';

  meta = with lib; {
    homepage = "https://github.com/xiao-e-yun/PostArchiverViewer";
    license = licenses.bsd3;
    maintainers = with maintainers; [ AyaseFile ];
    mainProgram = "post-archiver-viewer";
  };
}
