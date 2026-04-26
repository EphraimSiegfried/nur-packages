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

    logLevel = mkOption {
      type = types.enum [
        "debug"
        "info"
        "warn"
        "error"
      ];
      default = "info";
      description = "Log level for Bindery.";
    };

    downloadDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Directory where the download client places completed downloads.";
    };

    libraryDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Destination directory for imported ebook files.";
    };

    audiobookDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Destination directory for imported audiobook folders. Falls back to libraryDir if not set.";
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

      environment =
        {
          BINDERY_PORT = toString cfg.port;
          BINDERY_DATA_DIR = cfg.dataDir;
          BINDERY_DB_PATH = "${cfg.dataDir}/bindery.db";
          BINDERY_LOG_LEVEL = cfg.logLevel;
        }
        // lib.optionalAttrs (cfg.downloadDir != null) {
          BINDERY_DOWNLOAD_DIR = cfg.downloadDir;
        }
        // lib.optionalAttrs (cfg.libraryDir != null) {
          BINDERY_LIBRARY_DIR = cfg.libraryDir;
        }
        // lib.optionalAttrs (cfg.audiobookDir != null) {
          BINDERY_AUDIOBOOK_DIR = cfg.audiobookDir;
        };

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        User = "bindery";
        Group = "bindery";
        StateDirectory = "bindery";
        StateDirectoryMode = "0750";
        ReadWritePaths =
          [ cfg.dataDir ]
          ++ lib.optional (cfg.downloadDir != null) cfg.downloadDir
          ++ lib.optional (cfg.libraryDir != null) cfg.libraryDir
          ++ lib.optional (cfg.audiobookDir != null) cfg.audiobookDir;
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
