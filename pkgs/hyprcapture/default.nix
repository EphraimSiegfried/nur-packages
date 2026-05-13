{
  lib,
  fetchFromGitHub,
  cmake,
  hyprlandPlugins,
  hyprland,
  qt6,
  kdePackages,
  nlohmann_json,
  ffmpeg,
  glib,
  lua,
  libdrm,
  wl-clipboard,
  gpu-screen-recorder,
}:

hyprlandPlugins.mkHyprlandPlugin {
  pluginName = "hyprcapture";
  version = "0.1.0-unstable-2026-05-03";

  src = fetchFromGitHub {
    owner = "gfhdhytghd";
    repo = "HyprCapture";
    rev = "424be14dd63c68c6c28e798162e6e0a2420f20e4";
    hash = "sha256-ntd4qtJ7VU0E5m86QjUph3Sc0coMuGq+BVhu7WafB+k=";
  };

  # Patch for compatibility with LayerShellQt < 6.6
  postPatch = ''
    substituteInPlace src/ui/main.cpp \
      --replace-fail '#if LAYERSHELLQTINTERFACE_ENABLE_DEPRECATED_SINCE(6, 6)' '#if 1'
    substituteInPlace src/ui/capture_overlay.cpp \
      --replace-fail 'layerWindow->setActivateOnShow(true);' '// layerWindow->setActivateOnShow(true);'
    substituteInPlace src/ui/result_thumbnail.cpp \
      --replace-fail 'layerWindow->setActivateOnShow(false);' '// layerWindow->setActivateOnShow(false);'
  '';

  env.NIX_CFLAGS_COMPILE = "-isystem ${lib.getDev libdrm}/include/libdrm";

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    kdePackages.layer-shell-qt
    nlohmann_json
    ffmpeg
    glib
    lua
    libdrm
  ];

  postInstall = ''
    qtWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [
      wl-clipboard
      gpu-screen-recorder
    ]})
  '';

  meta = {
    description = "Screenshot and screen recording tool for Hyprland";
    homepage = "https://github.com/gfhdhytghd/HyprCapture";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "hyprshot-ui";
  };
}
