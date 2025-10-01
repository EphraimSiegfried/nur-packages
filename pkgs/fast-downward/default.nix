{
  lib,
  fetchzip,
  python3Packages,
  writeText,
  callPackage,
  withSoplex ? true,
  # Don't always install cplex because it is not supported on all systems
  withCplex ? false,
  ...
}:

let
  pname = "fast-downward";
  version = "24.06.1";
  src = fetchzip {
    url = "https://www.fast-downward.org/latest/files/release${lib.versions.majorMinor version}/fast-downward-${version}.tar.gz";
    sha256 = "sha256-JwBdV44h6LAJeIjKHPouvb3ZleydAc55QiuaFGrFx1Y=";
  };

  downward = callPackage ./downward.nix {
    inherit
      src
      version
      withSoplex
      withCplex
      ;
  };
in
# Build the driver
python3Packages.buildPythonPackage rec {
  inherit pname version src;
  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  configurePhase =
    let
      # The original Python module doesn't comply with PIP's packaging standards
      # Need to add a setup script
      setupPy = writeText "setup.py" ''
        from setuptools import setup, find_packages
        setup(
          name='${pname}',
          version='${version}',
          packages=['driver', 'driver/portfolios'],
          entry_points={
            'console_scripts':['fast-downward=driver.main:main']
          },
        )
      '';
    in
    ''
      ln -s ${setupPy} setup.py
    '';

  # The driver hardcodes the location of the core downward implementation
  # Need to link the hardcoded path to the correct path in the nix store
  postInstall = ''
    mkdir -p $out/${python3Packages.python.sitePackages}/builds/release/bin
    ln -s ${downward}/lib/downward $out/${python3Packages.python.sitePackages}/builds/release/bin/downward
    ln -s ${downward}/lib/translate $out/${python3Packages.python.sitePackages}/builds/release/bin/translate
  '';

  # Disable tests
  docheck = false;
}
