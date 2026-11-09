{ pkgs, lib, config, ... }:
let
  cfg = config.services.openrig;
  openrig = pkgs.callPackage ../../packages/openrig.nix { };
in {
  options.services.openrig = {
    enable = lib.mkEnableOption "OpenRig multi-agent orchestration daemon";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3030;
      description = "Port for the OpenRig daemon web dashboard and RPC server.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Host address for OpenRig to bind on.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/local/appdata/openrig";
      description = "State directory where OpenRig stores SQLite databases and workspaces.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open the OpenRig port in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.openrig = {
      isSystemUser = true;
      uid = 979;
      group = "openrig";
      extraGroups = [ "kvm" ]; # Hardware virtualization for Gondolin micro-VM sandboxing
      home = cfg.stateDir;
      createHome = true;
      description = "OpenRig multi-agent daemon service user";
    };

    users.groups.openrig = {
      gid = 979;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.tmpfiles.rules = [
      "d /mnt/local/appdata 0755 root root -"
      "d ${cfg.stateDir} 0770 openrig openrig -"
      "d ${cfg.stateDir}/workspace 0770 openrig openrig -"
      "d ${cfg.stateDir}/.openrig 0770 openrig openrig -"
    ];

    systemd.services.openrig = {
      description = "OpenRig Multi-Agent Coordination Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      path = [
        pkgs.tmux
        pkgs.git
        pkgs.openssh
        pkgs.qemu
        pkgs.coreutils
      ];

      environment = {
        HOME = cfg.stateDir;
        OPENRIG_HOME = "${cfg.stateDir}/.openrig";
      };

      serviceConfig = {
        Type = "forking";
        User = "openrig";
        Group = "openrig";
        WorkingDirectory = cfg.stateDir;
        ExecStart = "${openrig}/bin/rig daemon start --port ${toString cfg.port} --host ${cfg.host} --db ${cfg.stateDir}/openrig.db";
        ExecStop = "${openrig}/bin/rig daemon stop";
        Restart = "on-failure";
        RestartSec = 5;
        KillMode = "process";
        EnvironmentFile = lib.mkIf (config.age.secrets ? ai-api-keys) config.age.secrets.ai-api-keys.path;
      };
    };

    environment.systemPackages = [ openrig pkgs.tmux ];
  };
}
