{ ... }: {
  # Web UI available at http://<host>:2283
  services.immich = {
    enable = true;
    mediaLocation = "/mnt/local/appdata/immich";
    openFirewall = true;
  };

  # Ensure the appdata directory exists with correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata         0750 root    root    -"
    "d /mnt/local/appdata/immich  0750 immich  immich  -"
  ];
}
