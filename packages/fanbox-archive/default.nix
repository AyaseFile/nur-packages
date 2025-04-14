{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "FanboxArchive";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "xiao-e-yun";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-kbElU/ihUL9VwV1CFIFkvD9lhNRFGj5Or8pDf9wGW8I=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-AvZ/vbICOAhkcG6zhENNq0UFEOr7xFPp6ejHsQHroHE=";

  RUSTC_BOOTSTRAP = 1;
  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/fanbox-archive -h > /dev/null
  '';

  meta = with lib; {
    homepage = "https://github.com/xiao-e-yun/FanboxArchive";
    license = licenses.bsd3;
    maintainers = with maintainers; [ AyaseFile ];
    mainProgram = "fanbox-archive";
  };
}
