{
  src,
  version,
  pkgs,
  stdenv,
  lib,
  makeWrapper,
  withSoplex,
  withCplex,
  ...
}:
# Build the core C++ implementation
# Cmake also copies a 'translate' Python module to the out directory
stdenv.mkDerivation {
  pname = "downward";
  inherit version src;

  nativeBuildInputs = [
    pkgs.cmake
    makeWrapper
  ];

  # Conditionally include soplex and cplex in buildInputs
  buildInputs =
    with pkgs;
    lib.optionals withSoplex [
      soplex
      gmp
    ]
    ++ lib.optionals withCplex [ cplex ];

  cmakeFlags = [ "-S ../src" ];

  # Set soplex_DIR and cplex_DIR for the build process if they are present
  env =
    (lib.optionalAttrs withSoplex {
      soplex_DIR = "${lib.getExe pkgs.soplex}";
    })
    // (lib.optionalAttrs withCplex {
      cplex_DIR = "${lib.getExe pkgs.cplex}";
    });

  installPhase = ''
    mkdir -p $out/lib
    mv bin/* $out/lib
  '';

  # Make soplex_DIR and cplex_DIR available at runtime if they are present
  postInstall = ''
    wrapProgram $out/lib/downward \
    	    ${lib.optionalString withSoplex "--set soplex_DIR ${lib.getExe pkgs.soplex}"} \
    	    ${lib.optionalString withCplex "--set cplex_DIR ${lib.getExe pkgs.cplex}"} \
  '';
}
