{pkgs, ...}: {
  # Web UI available at http://<host>:8096
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver # previously vaapiIntel
      libva-vdpau-driver
      # vaapiVdpau #Had errors with this one, replaced with above
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      # vpl-gpu-rt # QSV on 11th gen or newer
      # intel-media-sdk # QSV up to 11th gen - DISABLED: marked insecure due to CVEs
    ];
  };
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    dataDir = "/mnt/local/appdata/jellyfin";
    cacheDir = "/mnt/local/cache/jellyfin";
  };

  # Ensure the appdata/cache directories exist with correct ownership
  # configDir and logDir default to subdirs of dataDir, so they are created automatically
  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata             0755 root     root     -"
    "d /mnt/local/appdata/jellyfin    0700 jellyfin jellyfin -"
    "d /mnt/local/cache               0755 root     root     -"
    "d /mnt/local/cache/jellyfin      0700 jellyfin jellyfin -"
  ];

  users.users.jellyfin = {
    extraGroups = [
      "video"
      "render"
    ];
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
}