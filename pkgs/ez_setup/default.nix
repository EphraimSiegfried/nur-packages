{
  lib,
  python313,
  fetchFromGitHub,
}:

python313.pkgs.buildPythonApplication rec {
  pname = "ez_setup";
  version = "0.9";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ActiveState";
    repo = "ez_setup";
    rev = "v${version}";
    hash = "sha256-LEzQilkH8F7zJq82HLJW3pk63bNjT45ubJEejoc9vMc=";
  };

  build-system = with python313.pkgs; [
    setuptools
    wheel
    distutils
  ];

  pythonImportsCheck = [
    "ez_setup"
  ];

  meta = {
    description = "Ez_setup.py and distribute_setup.py";
    homepage = "https://github.com/ActiveState/ez_setup";
    # license = lib.licenses.unfree; # FIXME: nix-init did not find a license
    maintainers = with lib.maintainers; [ ];
    mainProgram = "ez-setup";
  };
}
