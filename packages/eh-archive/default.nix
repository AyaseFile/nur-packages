{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "EhArchive";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "AyaseFile";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-n7LalbXXnMNHgwYrIcCFCw76DX3jUuQg8a6nOJcmbNg=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-KiVpby5wqQWQpBLg5c/Sd016PdmHDZV9GkpT5NYq7Sk=";

  env.RUSTC_BOOTSTRAP = 1;
  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/eh-archive -h > /dev/null
  '';

  meta = with lib; {
    homepage = "https://github.com/AyaseFile/EhArchive";
    license = licenses.gpl3;
    maintainers = with maintainers; [ AyaseFile ];
    mainProgram = "eh-archive";
  };
}
