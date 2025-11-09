{
  pkgs,
  fetchFromGitHub,
  python3Packages,
  writeText,
  callPackage,
  withSoplex ? true,
  versionCheckHook,
  lib,
}:

let
  pname = "fast-downward";
  version = "24.06.1";
  src = fetchFromGitHub {
    owner = "aibasel";
    repo = "downward";
    rev = "release-24.06.1";
    hash = "sha256-cv26tdJubUxzwDV6xeT+eWIAd63KJdx15E6ABMGaE98=";
    # if forceFetchGit is not set, the misc directory with the tests is not fetched
    forceFetchGit = true;
  };

  downward = callPackage ./downward.nix {
    inherit
      src
      version
      withSoplex
      ;
  };
in
# Build the driver
python3Packages.buildPythonPackage rec {
  inherit pname version src;
  pyproject = true;
  build-system = [ python3Packages.setuptools ];
  nativeCheckInputs = [
    python3Packages.pytest
    pkgs.gcc
    pkgs.libclang
    versionCheckHook
  ];

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
    mkdir -p $out/${python3Packages.python.sitePackages}/builds/{release,debug}/bin
    ln -s ${downward}/lib/release/downward $out/${python3Packages.python.sitePackages}/builds/release/bin/downward
    ln -s ${downward}/lib/release/translate $out/${python3Packages.python.sitePackages}/builds/release/bin/translate
    ln -s ${downward}/lib/debug/downward $out/${python3Packages.python.sitePackages}/builds/debug/bin/downward
    ln -s ${downward}/lib/debug/translate $out/${python3Packages.python.sitePackages}/builds/debug/bin/translate
  '';

  checkPhase = ''
    mkdir -p builds/{release,debug}/bin
    ln -s ${downward}/lib/release/downward builds/release/bin/downward
    ln -s ${downward}/lib/release/translate builds/release/bin/translate
    ln -s ${downward}/lib/debug/downward builds/debug/bin/downward
    ln -s ${downward}/lib/debug/translate builds/debug/bin/translate

    versionCheckHook
    # need to cd else relative path resolving in the tests does not work
    cd misc/tests
    python test-translator.py benchmarks all
    python test-parameters.py
    pytest test-exitcodes.py
  '';

  meta = with lib; {
    description = "Domain-independent classical planning system";
    homepage = "https://www.fast-downward.org";
    license = licenses.gpl3;
    maintainers = with maintainers; [ EphraimSiegfried ];
    mainProgram = "fast-downward";
  };

}
