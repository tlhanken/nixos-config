{ ... }: {
  # Web UI available at http://<host>:8222
  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_PORT = 8222;
      ROCKET_ADDRESS = "0.0.0.0";
      DATA_FOLDER = "/mnt/local/appdata/vaultwarden";
      SIGNUPS_ALLOWED = false;
    };
  };

  # Allow the service to write to its external data folder
  systemd.services.vaultwarden.serviceConfig.ReadWritePaths = [ "/mnt/local/appdata/vaultwarden" ];

  # Open firewall for vaultwarden
  networking.firewall.allowedTCPPorts = [ 8222 ];

  # Ensure the appdata directory exists with correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata             0755 root         root         -"
    "d /mnt/local/appdata/vaultwarden 0750 vaultwarden  vaultwarden  -"
  ];
}
