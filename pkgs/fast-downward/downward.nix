{
  src,
  version,
  pkgs,
  stdenv,
  lib,
  makeWrapper,
  withSoplex,
  cmake,
}:
# Build the core C++ implementation
# Cmake also copies a 'translate' Python module to the out directory
stdenv.mkDerivation {
  pname = "downward";
  inherit version src;

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  # Conditionally include soplex
  buildInputs =
    with pkgs;
    lib.optionals withSoplex [
      soplex
      gmp
    ];

  # Set cplex_DIR for the build process if present
  env = (
    lib.optionalAttrs withSoplex {
      soplex_DIR = "${pkgs.soplex}";
    }
  );

  configurePhase = ''
    mkdir builds
    cmake -S src -O builds/release -DCMAKE_BUILD_TYPE=Release
    cmake -S src -O builds/debug -DCMAKE_BUILD_TYPE=Debug
  '';

  buildPhase = ''
    cmake --build builds/release -j 14
    cmake --build builds/debug -j 14
  '';

  installPhase = ''
    mkdir -p $out/lib/{release,debug}
    mv builds/release/bin/* $out/lib/release
    mv builds/debug/bin/downward $out/lib/debug
    ln -s $out/lib/release/translate $out/lib/debug/translate
  '';

  # Make soplex_DIR available at runtime if present
  postInstall = ''
    wrapProgram $out/lib/release/downward \
        ${lib.optionalString withSoplex "--set soplex_DIR ${pkgs.soplex}"} \
        
    wrapProgram $out/lib/debug/downward \
        ${lib.optionalString withSoplex "--set soplex_DIR ${pkgs.soplex}"} \
  '';

  meta = with lib; {
    description = "Domain-independent classical planning system";
    homepage = "https://www.fast-downward.org";
    license = licenses.gpl3;
    maintainers = with maintainers; [ EphraimSiegfried ];
    mainProgram = "downward";
  };
}
