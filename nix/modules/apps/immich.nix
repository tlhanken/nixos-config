{ ... }: {
  # Web UI available at http://<host>:2283
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    mediaLocation = "/mnt/local/appdata/immich";
    openFirewall = true;
  };

  # Ensure the appdata, photos/tlhanken, and library directories exist with correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata                 0755 root    root    -"
    "d /mnt/local/appdata/immich          0755 immich  immich  -"
    "d /mnt/local/appdata/immich/library  0775 immich  users   -"
    "d /mnt/local/photos                  0775 root    users   -"
    "d /mnt/local/photos/tlhanken         0775 immich  users   -"
  ];

  users.users.immich = {
    extraGroups = [ "users" ];
  };
}
