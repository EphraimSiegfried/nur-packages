{ self, ... }:
{
  perSystem =
    { self', pkgs, ... }:
    {
      checks.lazylibrarian = pkgs.testers.runNixOSTest ({
        name = "lazylibrarian";
        nodes = {
          server = {
            imports = [ self.nixosModules.lazylibrarian ];
            services.lazylibrarian = {
              enable = true;
              package = self'.packages.lazylibrarian;
            };

          };
        };

        testScript = # python
          ''
            server.succeed("systemctl status lazylibrarian")
          '';
      });
    };
}
