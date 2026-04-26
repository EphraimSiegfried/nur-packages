{
  pkgs,
  self,
  ...
}:
pkgs.testers.runNixOSTest {
  name = "bindery";

  nodes.machine =
    { ... }:
    {
      imports = [ self.nixosModules.bindery ];

      services.bindery = {
        enable = true;
        package = self.packages.${pkgs.system}.bindery;
        port = 8787;
      };
    };

  testScript = ''
    machine.wait_for_unit("bindery.service")
    machine.wait_for_open_port(8787)
    machine.succeed("curl --fail http://localhost:8787/api/v1/health")
  '';
}
