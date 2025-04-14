{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "EhArchive";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "AyaseFile";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-fNvM2Rhu34Ho4lZvEHFZZJwbaPamGn8xMJSLToBZIPs=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-anO+h5ADpOZk2LyqDvMhfoCGBvkBgOJlkneiUqibZ/U=";

  env.RUSTC_BOOTSTRAP = 1;
  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ];

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail "[package]" ''$'cargo-features = ["edition2024"]\n[package]'
  '';

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
