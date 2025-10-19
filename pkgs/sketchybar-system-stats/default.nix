{
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sketchybar-system-stats";
  version = "0.7.1";
  src = fetchFromGitHub {
    owner = "joncrangle";
    repo = "sketchybar-system-stats";
    rev = "0603a96";
    hash = "sha256-kXeidDPpVcyMe7lLt+KRgzOiWKvZGbUfAB5saVR4qK0=";
  };
  cargoHash = "sha256-GwHxLzr5HIhFae3OnEFVBQLDoXQbmgS0R/8CV40FlQ4=";
})
