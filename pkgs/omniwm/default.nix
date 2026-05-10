{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  _7zz,
}:

stdenvNoCC.mkDerivation rec {
  pname = "omniwm";
  version = "0.4.8.1";

  src = fetchurl {
    url = "https://github.com/BarutSRB/OmniWM/releases/download/v${version}/OmniWM-v${version}.zip";
    hash = "sha256-f2ByexWwgc9qzUC0wbXf0nDIMl4w1xtuUfXpmzA/CFc=";
  };

  nativeBuildInputs = [ _7zz ];

  sourceRoot = "OmniWM.app";

  unpackCmd = "7zz x $curSrc";

  installPhase = ''
    runHook preInstall
    find . -name '._*' -delete
    mkdir -p "$out/Applications/OmniWM.app"
    cp -R . "$out/Applications/OmniWM.app"
    mkdir -p "$out/bin"
    ln -s "$out/Applications/OmniWM.app/Contents/MacOS/omniwmctl" "$out/bin/omniwmctl"
    runHook postInstall
  '';

  meta = {
    description = "A macOS tiling window manager inspired by Niri and Hyprland";
    homepage = "https://github.com/BarutSRB/OmniWM";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    mainProgram = "omniwmctl";
  };
}
