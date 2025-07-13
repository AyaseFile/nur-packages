{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "EhArchive";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "AyaseFile";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-N33uUgkHZmdPGWfpxIzAuVeaX+9N5AG9DZcgVK717aI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-h34+w29Y9+vAXpFF0+Pa7FX68eoT50JHqPv95xvQq9c=";

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
