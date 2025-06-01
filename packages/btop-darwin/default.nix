# from https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/bt/btop/package.nix
{
  lib,
  fetchpatch,
  stdenv,
  fetchFromGitHub,
  cmake,
  removeReferencesTo,
  apple-sdk_15,
  versionCheckHook,
}:

stdenv.mkDerivation rec {
  pname = "btop";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "aristocratos";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-4x2vGmH2dfHZHG+zj2KGsL/pRNIZ8K8sXYRHy0io5IE=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ apple-sdk_15 ];

  installFlags = [ "PREFIX=$(out)" ];

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
