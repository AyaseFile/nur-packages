{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "nightly";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "51777daedbe4783c3b79f0246d775e4b6d978cbc";
    sha256 = "sha256-cFaFgChhpgEiJw+dHl3Hr3T2UQF+Vy6u36JWY+cYBNo=";
  };

  installPhase = ''
    mkdir -p $out/share/rime-data
    cp -r * $out/share/rime-data/
  '';

  meta = with lib; {
    homepage = "https://github.com/iDvel/rime-ice";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ AyaseFile ];
  };
}
