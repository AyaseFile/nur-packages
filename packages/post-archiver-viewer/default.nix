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
  version = "0.2.9";

  src = fetchFromGitHub {
    owner = "xiao-e-yun";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-EDQd/6QmI+bxHD/rDYLlgujqNaxjqTQrNf+V6ZW/Rkg=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-YNQZbCLDRHb8LphqZbpj8GHW2T7LX9YbIpX2v35AWWQ=";

  offlineCache = fetchYarnDeps {
    yarnLock = yarnLock;
    sha256 = "sha256-emP4shFphJIO06qXbSeLx6vPbzkNJzTxt+TotnizwLw=";
  };

  env.RUSTC_BOOTSTRAP = 1;
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
