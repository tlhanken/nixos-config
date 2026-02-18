{pkgs, ...}: {
  users.users.ollama = {
    isNormalUser = false;
    description = "Ollama";
  };
  services.ollama = {
    enable = true;
    home = "/mnt/ollama";
    acceleration = "rocm";  #cuda for nvidia, ROCm for amd
    user = "ollama";
  };

  # Enable ROCm
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };
}