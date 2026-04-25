{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.bindery;
in
{
  options.services.bindery = with lib; {
    enable = mkEnableOption "Bindery, an automated book download manager for Usenet and torrents";
    package = mkPackageOption pkgs "bindery" { };

    port = mkOption {
      type = types.port;
      default = 8787;
      description = "Port Bindery listens on.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the firewall for Bindery's port.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/bindery";
      description = "Directory for Bindery's data and database.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.bindery = {
      isSystemUser = true;
      group = "bindery";
      home = cfg.dataDir;
      createHome = true;
      description = "Bindery service user";
    };

    users.groups.bindery = { };

    systemd.services.bindery = {
      description = "Bindery book download manager";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
      after = [ "network.target" ];

      environment = {
        BINDERY_PORT = toString cfg.port;
        BINDERY_DATA_DIR = cfg.dataDir;
        BINDERY_DB_PATH = "${cfg.dataDir}/bindery.db";
      };

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        User = "bindery";
        Group = "bindery";
        StateDirectory = "bindery";
        StateDirectoryMode = "0750";
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
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
        SystemCallArchitectures = "native";
        PrivateNetwork = false;
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
