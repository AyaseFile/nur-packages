{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "PatreonArchive";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "xiao-e-yun";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Icdd+dGqsum2BNvhqv8LA+LaepcN2tYEsk9widnmS3A=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-4i7/dF+l5GJyz3ti6jIq93QtPOE+Xwy/MciGD0Re8H0=";

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
