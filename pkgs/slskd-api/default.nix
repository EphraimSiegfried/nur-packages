{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "slskd-api";
  version = "0.2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bigoulours";
    repo = "slskd-python-api";
    rev = "v${version}";
    hash = "sha256-rEfBT13NutwCfrWcxQf67rhtmxlB8Ws6RY8fObidSs8=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
    python3.pkgs.setuptools-git-versioning
    python3.pkgs.requests
  ];

  pythonImportsCheck = [
    "slskd_api"
  ];

  meta = {
    description = "A python wrapper for the slskd api";
    homepage = "https://github.com/bigoulours/slskd-python-api";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "slskd-api";
  };
}
