{
  lib,
  python3,
  fetchFromGitLab,
  iso639-lang,
  slskd-api,
  ez_setup,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "lazy-librarian";
  version = "unstable-2026-04-20";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "LazyLibrarian";
    repo = "LazyLibrarian";
    rev = "652b2d0d30a68e3034339554c6f6113cf0581521";
    hash = "sha256-FpqVFwhaeXncFvn4dwcm9Qf57aty9JeFMnYUVzoJhgk=";
  };

  build-system = [
    python3.pkgs.setuptools
    ez_setup
  ];

  dependencies = with python3.pkgs; [
    apprise
    apscheduler
    beautifulsoup4
    cherrypy
    cherrypy-cors
    deluge-client
    html5lib
    httpagentparser
    httplib2
    irc
    lxml
    mako
    pillow
    pyopenssl
    pyparsing
    pypdf
    python-magic
    rapidfuzz
    requests
    tzdata
    urllib3
    webencodings
    xmltodict
    iso639-lang
    slskd-api
  ];
  # covered by beautifulsoup4
  pythonRemoveDeps = [ "bs4" ];

  postInstall = ''
    share=$out/share/lazy-librarian
    mkdir -p "$share"
    cp -r . "$share"

    # Prevent LazyLibrarian from attempting a self-update on first run.
    # It looks for a VERSION file to determine install type; "win32" skips
    # the git-based update path entirely.
    echo "win32" > "$share/VERSION"

    makeWrapper ${python3.interpreter} $out/bin/lazy-librarian \
      --add-flags "$share/LazyLibrarian.py" \
      --set PYTHONPATH "$PYTHONPATH"
  '';

  meta = {
    description = "LazyLibrarian is a SickBeard, CouchPotato, Headphones-like application for ebooks, audiobooks and magazines";
    homepage = "https://gitlab.com/LazyLibrarian/LazyLibrarian";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "lazy-librarian";
  };
}
