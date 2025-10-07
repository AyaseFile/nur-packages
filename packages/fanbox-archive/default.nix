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
  inherit (lib) optionalString escapeShellArg;
  unwrapped = rustPlatform.buildRustPackage rec {
    pname = "FanboxArchive-unwrapped";
    version = "0.6.1";

    src = fetchFromGitHub {
      owner = "xiao-e-yun";
      repo = "FanboxArchive";
      rev = "v${version}";
      sha256 = "sha256-U6FT/y/hb7hY6tlyb821Y26tsHwS/1XRKHi8sIHiJOY=";
    };

    cargoHash = "sha256-s+6B04pbcMC4PGTkpIPqBJv4cUGeejtWmzWb1yViGKY=";

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
      $out/bin/fanbox-archive -h > /dev/null
    '';
  };
in
stdenv.mkDerivation {
  pname = "FanboxArchive";
  version = unwrapped.version;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${unwrapped}/bin/fanbox-archive $out/bin/fanbox-archive \
      ${optionalString (args != { }) ''
        ${
          optionalString (
            args ? "userAgent" && args.userAgent != null
          ) ''--add-flags "--user-agent ${escapeShellArg args.userAgent}"''
        } \
        ${
          optionalString (
            args ? "cookies" && args.cookies != null
          ) ''--add-flags "--cookies ${escapeShellArg args.cookies}"''
        } \
        ${optionalString (args ? "extraArgs" && args.extraArgs != "") ''--add-flags "${args.extraArgs}"''} \
        --set FANBOXSESSID "${args.session}" \
        --set OUTPUT "${args.output}"
      ''}
  '';

  meta = with lib; {
    homepage = "https://github.com/xiao-e-yun/FanboxArchive";
    license = licenses.bsd3;
    maintainers = with maintainers; [ AyaseFile ];
    mainProgram = "fanbox-archive";
  };
}
