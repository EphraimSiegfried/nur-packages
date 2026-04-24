{ lib, ... }:
let
  module_dir = ../nixos-modules;
  modules = builtins.readDir module_dir |> builtins.attrNames;
  module_names = map (lib.removeSuffix ".nix") modules;
  module_paths = map (name: lib.path.append module_dir name) modules;

  module_names_to_paths = builtins.listToAttrs (
    lib.lists.zipListsWith (name: value: { inherit name value; }) module_names module_paths
  );
in
{
  flake.nixosModules = module_names_to_paths;
}
