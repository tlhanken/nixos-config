{pkgs, ...}: let
  nextcloudHostname = "nextcloud.local";
  nextcloudDataDir = "/mnt/local/appdata/nextcloud";
in {
  # Web UI available at https://<host> (proxied via nginx)
  services.nextcloud = {
    enable = true;
    hostName = nextcloudHostname;
    package = pkgs.nextcloud30;
    datadir = nextcloudDataDir;
    https = true;

    config = {
      adminuser = "admin";
      adminpassFile = "/run/secrets/nextcloud-admin-pass";
      dbtype = "pgsql";
      dbhost = "/run/postgresql";
    };

    settings = {
      trusted_domains = [nextcloudHostname "localhost"];
      default_phone_region = "US";
    };
  };

  # PostgreSQL database for Nextcloud
  services.postgresql = {
    enable = true;
    ensureDatabases = ["nextcloud"];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
  };

  # Ensure PostgreSQL is ready before Nextcloud starts
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };

  # Open HTTP/HTTPS ports
  networking.firewall.allowedTCPPorts = [80 443];

  # Ensure the appdata directory exists with correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata              0755 root      root      -"
    "d /mnt/local/appdata/nextcloud    0750 nextcloud nextcloud -"
  ];
}