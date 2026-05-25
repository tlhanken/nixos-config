{pkgs, ...}: {
  users.users.ollama = {
    isSystemUser = true;
    description = "Ollama";
  };
  services.ollama = {
    enable = true;
    home = "/mnt/local/appdata/ollama";
    # acceleration = "rocm";  # Uncomment for AMD GPU, or use "cuda" for Nvidia. Leave disabled for Intel/CPU.
    user = "ollama";
  };

  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata/ollama 0770 ollama ollama -"
  ];
}