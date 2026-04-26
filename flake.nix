{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-modules/packages.nix
        ./flake-modules/overlay.nix
        ./flake-modules/nixos-modules.nix
        ./flake-modules/nixos-tests.nix
      ];
    };
}
