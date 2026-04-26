{ lib, config, ... }:
let
  test_dir = ../nixos-tests;
  tests = builtins.readDir test_dir |> builtins.attrNames;
  test_names = map (lib.removeSuffix ".nix") tests;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks = lib.genAttrs test_names (
        name:
        import (lib.path.append test_dir "${name}.nix") {
          inherit pkgs;
          self = config.flake;
        }
      );
    };
}
