{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "iso639-lang";
  version = "2.6.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "LBeaudoux";
    repo = "iso639";
    rev = "v${version}";
    hash = "sha256-ORqSrf84b/ddpCUi9e43ur6C+XcJjQGM+fmJ8e/wFus=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  pythonImportsCheck = [
    "iso639"
  ];

  meta = {
    description = "A fast, comprehensive, ISO\u{a0}639 library";
    homepage = "https://github.com/LBeaudoux/iso639";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "iso639";
  };
}
