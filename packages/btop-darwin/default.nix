# from https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/bt/btop/package.nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  removeReferencesTo,
  apple-sdk_15,
  versionCheckHook,
}:

stdenv.mkDerivation rec {
  pname = "btop";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "aristocratos";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-4H9UjewJ7UFQtTQYwvHZL3ecPiChpfT6LEZwbdBCIa0=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ apple-sdk_15 ];

  installFlags = [ "PREFIX=$(out)" ];

  # fix build on darwin (see https://github.com/NixOS/nixpkgs/pull/422218#issuecomment-3039181870 and https://github.com/aristocratos/btop/pull/1173)
  cmakeFlags = [
    (lib.cmakeBool "BTOP_LTO" (!stdenv.hostPlatform.isDarwin))
  ];

  patches = [
    # https://github.com/aristocratos/btop/issues/845#issuecomment-2759769309
    ./darwin.patch
  ];

  postInstall = ''
    ${removeReferencesTo}/bin/remove-references-to -t ${stdenv.cc.cc} $(readlink -f $out/bin/btop)
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  meta = with lib; {
    description = "Monitor of resources";
    homepage = "https://github.com/aristocratos/btop";
    changelog = "https://github.com/aristocratos/btop/blob/v${version}/CHANGELOG.md";
    license = licenses.asl20;
    platforms = platforms.darwin;
    maintainers = with maintainers; [
      khaneliman
      rmcgibbo
      AyaseFile
    ];
    mainProgram = "btop";
  };
}
