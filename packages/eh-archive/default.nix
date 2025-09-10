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
    pname = "EhArchive-unwrapped";
    version = "0.1.6";

    src = fetchFromGitHub {
      owner = "AyaseFile";
      repo = "EhArchive";
      rev = "v${version}";
      sha256 = "sha256-N33uUgkHZmdPGWfpxIzAuVeaX+9N5AG9DZcgVK717aI=";
    };

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
  };
in
stdenv.mkDerivation {
  pname = "EhArchive";
  version = unwrapped.version;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${unwrapped}/bin/eh-archive $out/bin/eh-archive \
      ${optionalString (args != { }) ''
        --add-flags "--port ${toString args.port}" \
        --add-flags "--archive-output ${args.archiveOutput}" \
        --add-flags "--library-root ${args.libraryRoot}" \
        --add-flags "--tag-db-root ${args.tagDbRoot}" \
        --add-flags "--limit ${toString args.limit}" \
        --set EH_SITE "${args.site}" \
        --set EH_AUTH_ID "${args.memberId}" \
        --set EH_AUTH_HASH "${args.passHash}" \
        ${optionalString (
          args ? "igneous" && args.igneous != null
        ) ''--set EH_AUTH_IGNEOUS "${args.igneous}"''}
      ''}
  '';

  meta = with lib; {
    homepage = "https://github.com/AyaseFile/EhArchive";
    license = licenses.gpl3;
    maintainers = with maintainers; [ AyaseFile ];
    mainProgram = "eh-archive";
  };
}
