{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.lazylibrarian;
  fmt = pkgs.formats.ini { };
in
{
  options.services.lazylibrarian = with lib; {
    enable = mkEnableOption "An automated manager that tracks and downloads eBooks and audiobooks for your digital library";
    package = mkPackageOption pkgs "lazylibrarian" { };

    port = mkOption {
      type = types.port;
      default = 5299;
      description = "Port LazyLibrarian listens on.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the firewall for LazyLibrarian's port.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/lazylibrarian";
      description = "Directory for LazyLibrarian's data.";
    };

    settings = mkOption {
      description = "Values that are passed to config.ini. Check https://lazylibrarian.gitlab.io/";
      default = { };
      example = {
        general = {
          http_host = "localhost";
          logdir = "/var/lib/lazylibrarian/logs";
        };
        useraccounts = {
          user_accounts = true;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.lazylibrarian = {
      description = "LazyLibrarian ebook/audiobook manager";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
      after = [ "network.target" ];

      script = "${cfg.package}/bin/lazylibrarian --datadir=${cfg.dataDir} --config=${
        fmt.generate "lazylibrarian-config.ini" (
          lib.recursiveUpdate {
            general = {
              http_port = cfg.port;
              install_type = "source";
              auto_update = false;
            };
          } cfg.settings
        )
      }";

      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "lazylibrarian";

        ReadWritePaths = [ cfg.dataDir ];
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;

        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;

        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
        SystemCallArchitectures = "native";

        PrivateNetwork = false; # needs network access
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
