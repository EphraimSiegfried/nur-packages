{
  stdenv,
  fetchFromGitHub,
  meson,
  cmake,
  pkg-config,
  cli11,
  ninja,
  git,
}:
let
  pname = "lv95-converter";
in
stdenv.mkDerivation {
  name = pname;
  version = "v1.1.2-git";
  src = fetchFromGitHub {
    owner = "tifrueh";
    repo = pname;
    rev = "f4d06";
    sha256 = "sha256-Bpi/GQFY/HpkrEOTxHb0cUIxEk0WWmjfuIeCkz9Oce8=";
  };
  nativeBuildInputs = [
    meson
    cmake
    pkg-config
    cli11
    ninja
    git
  ];
}
