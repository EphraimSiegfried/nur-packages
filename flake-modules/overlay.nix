let
  pkgNames = builtins.attrNames (builtins.readDir ../pkgs);
  overlay =
    final: _:
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value = final.callPackage ../pkgs/${name}/default.nix { };
      }) pkgNames
    );
in
{
  flake.overlays.default = overlay;
}
