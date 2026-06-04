{ pkgs, inputs, ... }: {
  users.users.comfyui = {
    isSystemUser = true;
    group = "comfyui";
    extraGroups = [ "video" "render" ]; # Required for GPU access
    home = "/mnt/local/appdata/comfyui";
    createHome = true;
    description = "ComfyUI Daemon User";
  };
  users.groups.comfyui = {};

  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata/comfyui 0770 comfyui comfyui -"
  ];

  # Run ComfyUI as a background service
  systemd.services.comfyui = {
    enable = true;
    description = "ComfyUI Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      # Fallback to default if comfyui package isn't specifically named
      ExecStart = "${inputs.nix-comfyui.packages.${pkgs.system}.cuda-comfyui}/bin/comfyui --listen 0.0.0.0 --port 8188 --cpu";
      User = "comfyui";
      Group = "comfyui";
      WorkingDirectory = "/mnt/local/appdata/comfyui";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # Also add it to system packages so you can run it manually if desired
  environment.systemPackages = [
    inputs.nix-comfyui.packages.${pkgs.system}.cuda-comfyui
  ];

  # Open port for local network access (like via Homepage)
  networking.firewall.allowedTCPPorts = [ 8188 ];
}
