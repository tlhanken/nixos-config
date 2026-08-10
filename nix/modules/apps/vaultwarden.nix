{ pkgs, ... }:
let
  net = import ../../lib/network.nix;
  domain = net.hosts.well-of-mimir-2.magicDns;
in
{
  # Web UI available at https://<host>:8443 (proxied via nginx with HTTPS for Web Crypto)
  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_PORT = 8222;
      ROCKET_ADDRESS = "127.0.0.1";
      DATA_FOLDER = "/mnt/local/appdata/vaultwarden";
      SIGNUPS_ALLOWED = false;
    };
  };

  # Allow the service to write to its external data folder
  systemd.services.vaultwarden.serviceConfig.ReadWritePaths = [ "/mnt/local/appdata/vaultwarden" ];

  # ── Tailscale Certificate Management ──────────────────────────────
  systemd.services.tailscale-cert-renew = {
    description = "Renew Tailscale TLS Certificate";
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/mkdir -p /var/lib/nginx/certs && ${pkgs.tailscale}/bin/tailscale cert --cert-file /var/lib/nginx/certs/${domain}.crt --key-file /var/lib/nginx/certs/${domain}.key ${domain} && ${pkgs.coreutils}/bin/chown -R nginx:nginx /var/lib/nginx/certs && ${pkgs.coreutils}/bin/chmod 750 /var/lib/nginx/certs && ${pkgs.coreutils}/bin/chmod 640 /var/lib/nginx/certs/*'";
    };
  };

  systemd.timers.tailscale-cert-renew = {
    description = "Timer to renew Tailscale TLS Certificate weekly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  # ── Nginx HTTPS Proxy for Vaultwarden (Port 8443) ─────────────────
  services.nginx.virtualHosts."vaultwarden-ssl" = {
    listen = [{ addr = "0.0.0.0"; port = 8443; ssl = true; }];
    onlySSL = true;
    sslCertificate = "/var/lib/nginx/certs/${domain}.crt";
    sslCertificateKey = "/var/lib/nginx/certs/${domain}.key";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8222";
      proxyWebsockets = true;
    };
  };

  # Open firewall for vaultwarden HTTPS port
  networking.firewall.allowedTCPPorts = [ 8222 8443 ];

  # Ensure the appdata directory exists with correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata             0755 root         root         -"
    "d /mnt/local/appdata/vaultwarden 0750 vaultwarden  vaultwarden  -"
    "d /var/lib/nginx/certs           0750 nginx        nginx        -"
  ];
}
