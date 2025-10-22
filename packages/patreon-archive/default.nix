{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  stdenv,
  makeWrapper,
  args ? { },
}:

let
  inherit (lib) optionalString;
  unwrapped = rustPlatform.buildRustPackage rec {
    pname = "PatreonArchive-unwrapped";
    version = "0.1.2";

    src = fetchFromGitHub {
      owner = "xiao-e-yun";
      repo = "PatreonArchive";
      rev = "v${version}";
      sha256 = "sha256-ckhHp4KiYUHMtb/jtAdbo8zWXoqr5bOYlNEZrFNr5Ds=";
    };

    cargoHash = "sha256-IcXYXGw79Wo9fKxiLFvtjAxfkVtMDsJK7V8a9m5kux8=";

    cargoPatches = [
      ./Cargo.lock.patch
    ];

    env.RUSTC_BOOTSTRAP = 1;
    nativeBuildInputs = [
      pkg-config
    ];
    buildInputs = [
      openssl
    ];

    postPatch = ''
      sed -i 's/^version = ".*"/version = "${version}"/' Cargo.toml
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      $out/bin/patreon-archive -h > /dev/null
    '';
  };
in
stdenv.mkDerivation {
  pname = "PatreonArchive";
  version = unwrapped.version;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${unwrapped}/bin/patreon-archive $out/bin/patreon-archive \
      ${optionalString (args != { }) ''
        ${optionalString (args ? "extraArgs" && args.extraArgs != "") ''--add-flags "${args.extraArgs}"''} \
        --set SESSION "${args.session}" \
        --set OUTPUT "${args.output}"
      ''}
  '';

  meta = with lib; {
    homepage = "https://github.com/xiao-e-yun/PatreonArchive";
    license = licenses.bsd3;
    maintainers = with maintainers; [ AyaseFile ];
    mainProgram = "patreon-archive";
  };
}
