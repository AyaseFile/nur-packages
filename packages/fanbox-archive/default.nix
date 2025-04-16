{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "FanboxArchive";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "xiao-e-yun";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-wIKyZs/U/A0gFR0lr2SnieHgMjv6LVQzjF3KTLUa0DM=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-Hu6zDkZDyRq0zk8I5RFsPuqiUgc+FQwqqOL7S2fqTOQ=";

  env.RUSTC_BOOTSTRAP = 1;
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
