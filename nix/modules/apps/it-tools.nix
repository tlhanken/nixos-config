{ pkgs, ... }: {
  # Web UI available at http://<host>:8400
  services.nginx = {
    enable = true;
    virtualHosts."it-tools" = {
      listen = [{ addr = "0.0.0.0"; port = 8400; ssl = false; }];
      root = "${pkgs.it-tools}/lib";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8400 ];
}
