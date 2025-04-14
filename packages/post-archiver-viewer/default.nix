{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  bun,
  nodejs,
}:

rustPlatform.buildRustPackage rec {
  pname = "PostArchiverViewer";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "xiao-e-yun";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-2V2UlkkzkTnD5EDmpOpxSWA4CBWkP1Dklztgg7iHGTw=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-oYIbDhSrWsZPp0aBv4KEX4e1Vb7GcUMltYlAzTY5rv0=";

  RUSTC_BOOTSTRAP = 1;
  nativeBuildInputs = [
    pkg-config
    bun
    nodejs
  ];
  buildInputs = [
    openssl
  ];

  preBuild = ''
    export HOME=$(mktemp -d)
    cd frontend
    bun install --frozen-lockfile
    bun run build
    cd ..
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
