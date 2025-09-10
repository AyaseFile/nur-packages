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
    version = "0.5.4";

    src = fetchFromGitHub {
      owner = "xiao-e-yun";
      repo = "FanboxArchive";
      rev = "v${version}";
      sha256 = "sha256-44hwdbr++NHie9/uIsVhp+E4/HgoJlznCf+kHE7jbGc=";
    };

    cargoHash = "sha256-z2P+DuoUsbkOG7QK8o222J05alpRgrAaMISAzaYYtHI=";

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
