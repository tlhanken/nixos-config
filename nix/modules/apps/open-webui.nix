{ pkgs, ... }: {
  services.open-webui = {
    enable = true;
    port = 8080;
    host = "0.0.0.0";
    stateDir = "/mnt/local/appdata/open-webui";
    # open-webui will automatically detect local ollama running on 11434
  };

  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata 0755 root root -"
    "d /mnt/local/appdata/open-webui 0770 open-webui open-webui -"
  ];


  networking.firewall.allowedTCPPorts = [ 8080 ];
}
