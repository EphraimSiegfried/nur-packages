# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:
let
  iso639-lang = pkgs.callPackage ./pkgs/iso639-lang { };
  slskd-api = pkgs.callPackage ./pkgs/slskd-api { };
  ez_setup = pkgs.callPackage ./pkgs/ez_setup { };
in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  example-package = pkgs.callPackage ./pkgs/example-package { };
  fast-downward = pkgs.callPackage ./pkgs/fast-downward { };
  sketchybar-system-stats = pkgs.callPackage ./pkgs/sketchybar-system-stats { };
  lv95-converter = pkgs.callPackage ./pkgs/lv95-converter { };
  inherit iso639-lang slskd-api ez_setup;

  lazylibrarian = pkgs.callPackage ./pkgs/lazylibrarian {
    inherit iso639-lang slskd-api ez_setup;
  };
}
