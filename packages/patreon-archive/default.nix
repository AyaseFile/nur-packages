{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "PatreonArchive";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "xiao-e-yun";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-4N1nYbOcEs0VEgoGf1MLXlMouVcQPdLyVd1BH5f2jy4=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-FCHypkDqjf4ugqU+ZU5PNd/duqijgV38mGJRmqDcNyQ=";

  env.RUSTC_BOOTSTRAP = 1;
  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/patreon-archive -h > /dev/null
  '';

  meta = with lib; {
    homepage = "https://github.com/xiao-e-yun/PatreonArchive";
    license = licenses.bsd3;
    maintainers = with maintainers; [ AyaseFile ];
    mainProgram = "patreon-archive";
  };
}
