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
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "xiao-e-yun";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-U+zyjRZTctFcgfpstS6sN9uJ09eTkcHPleyXXxne4bg=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-aXuU0DcKSoJuB7J/Aj1RG4IbkmLcPqPPCV9NtXk0nyA=";

  offlineCache = fetchYarnDeps {
    yarnLock = yarnLock;
    sha256 = "sha256-NDM/N6JedgaZMaqBLfU2vOEv9gB9qSpwbSzJpWQ1D7A=";
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
