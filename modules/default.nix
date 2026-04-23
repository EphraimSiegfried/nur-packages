{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.lazylibrarian;
in
{
  options.services.lazylibrarian = with lib; {
    enable = mkEnableOption "An automated manager that tracks and downloads eBooks and audiobooks for your digital library";
    package = mkPackageOption pkgs "lazylibrarian" { };
  };

  config.systemd.services.lazylibrarian = lib.mkIf cfg.enable {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" ];
    after = [ "network.target" ];

    script = "${cfg.package}/bin/lazy-librarian --config /tmp/lazylibrarian";
  };
}
