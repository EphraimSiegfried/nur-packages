{ lib, config, ... }:
{
  systems = lib.systems.flakeExposed;
  perSystem =
    { pkgs, ... }:
    let
      pkgNames = builtins.attrNames (builtins.readDir ../pkgs);
      pkgs' = pkgs.extend config.flake.overlays.default;
    in
    {
      packages = lib.genAttrs pkgNames (name: pkgs'.${name});
    };
}
