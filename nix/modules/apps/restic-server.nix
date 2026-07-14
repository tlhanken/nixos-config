{...}: {
  services.restic.server = {
    enable = true;
    dataDir = "/mnt/local/appdata/restic-server";
    # By default, restic-server uses no authentication if no htpasswd-file is given, but it might complain.
    # Listen on port 8000 by default.
    extraFlags = ["--no-auth"];
  };

  # Open the firewall port (default is 8000 for restic server)
  networking.firewall.allowedTCPPorts = [8000];

  # Ensure the appdata directories exist
  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata                0755 root   root   -"
    "d /mnt/local/appdata/restic-server  0700 restic restic -"
  ];
}
