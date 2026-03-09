{ ... }: {
  # Web UI available at http://<host>:2283
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    mediaLocation = "/mnt/local/appdata/immich";
    openFirewall = true;
  };

  # Ensure the appdata directory exists with correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata         0755 root    root    -"
    "d /mnt/local/appdata/immich  0750 immich  immich  -"
  ];
}
