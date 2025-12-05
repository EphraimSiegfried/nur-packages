{
  stdenv,
  fetchFromGitHub,
  meson,
  cmake,
  pkg-config,
  cli11,
  ninja,
}:
let
  pname = "lv95-converter";
in
stdenv.mkDerivation {
  name = pname;
  version = "1.1.2";
  src = fetchFromGitHub {
    owner = "tifrueh";
    repo = pname;
    rev = "b62906a";
    sha256 = "sha256-/srXVPVMqHvJzsAnmI7znVqHQ2rFFPPeV+NgNWMbVn0=";
  };
  nativeBuildInputs = [
    meson
    cmake
    pkg-config
    cli11
    ninja
  ];
}
