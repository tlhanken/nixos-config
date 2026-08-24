{ pkgs, ... }:
let
  net = import ../../lib/network.nix;
  domain = net.hosts.well-of-mimir-2.magicDns;
  port = 3000;
  sshPort = 2222;
in
{
  # Forgejo self-hosted Git server
  # Web UI available at http://<host>:3000
  # SSH access available on port 2222
  services.forgejo = {
    enable = true;
    stateDir = "/mnt/local/appdata/forgejo";
    database.type = "sqlite3";

    settings = {
      server = {
        DOMAIN = domain;
        HTTP_PORT = port;
        HTTP_ADDR = "0.0.0.0";
        ROOT_URL = "http://${domain}:${toString port}/";
        SSH_PORT = sshPort;
        SSH_LISTEN_PORT = sshPort;
        START_SSH_SERVER = true;
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
      repository = {
        DEFAULT_PRIVATE = "private";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ port sshPort ];

  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata         0755 root    root    -"
    "d /mnt/local/appdata/forgejo 0750 forgejo forgejo -"
  ];
}
