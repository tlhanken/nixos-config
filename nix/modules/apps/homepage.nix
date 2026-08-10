{ lib, ... }:
let
  net = import ../../lib/network.nix;
  port = 8082;
  hosts = [
    "localhost"
    "127.0.0.1"
    "well-of-mimir-2"
    net.hosts.well-of-mimir-2.magicDns
    net.hosts.well-of-mimir-2.ip
  ];
  allowedHosts = lib.concatStringsSep "," (
    lib.concatMap (h: [ h "${h}:${toString port}" ]) hosts
  );
in
{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = allowedHosts;

    settings = {
      title = "Home";
      theme = "dark";
      color = "slate";
      headerStyle = "clean";
      hideVersion = true;
    };

    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
          expanded = true;
        };
      }
      {
        datetime = {
          text_size = "xl";
          format = {
            dateStyle = "short";
            timeStyle = "short";
            hour12 = true;
          };
        };
      }
    ];

    services = [
      {
        "Media" = [
          {
            "Jellyfin" = {
              href = "http://${net.hosts.galar.magicDns}:8096";
              description = "Media server";
              icon = "jellyfin.png";
            };
          }
          {
            "Immich" = {
              href = "http://${net.hosts.well-of-mimir-2.magicDns}:2283";
              description = "Photo library";
              icon = "immich.png";
            };
          }
        ];
      }
      {
        "Tools" = [
          {
            "Vaultwarden" = {
              href = "https://${net.hosts.well-of-mimir-2.magicDns}:8443";
              description = "Password Manager";
              icon = "vaultwarden.png";
            };
          }
          {
            "Nextcloud" = {
              href = "https://nextcloud.local";
              description = "Cloud Storage & Sync";
              icon = "nextcloud.png";
            };
          }
          {
            "IT Tools" = {
              href = "http://${net.hosts.well-of-mimir-2.magicDns}:8400";
              description = "Developer utilities";
              icon = "it-tools.png";
            };
          }
          {
            "SearXNG" = {
              href = "http://${net.hosts.well-of-mimir-2.magicDns}:8888";
              description = "Private Search Engine";
              icon = "searxng.png";
            };
          }
        ];
      }
      {
        "AI" = [
          {
            "Open-WebUI" = {
              href = "http://${net.hosts.well-of-mimir-2.magicDns}:8080";
              description = "LLM Chat Interface";
              icon = "open-webui.png";
            };
          }
          {
            "ComfyUI" = {
              href = "http://${net.hosts.well-of-mimir-2.magicDns}:8188";
              description = "Stable Diffusion UI";
              icon = "comfyui.png";
            };
          }
          {
            "Hermes" = {
              href = "http://${net.hosts.well-of-mimir-2.magicDns}:8642";
              description = "Agent UI";
              icon = "mdi-robot-outline";
            };
          }
        ];
      }
    ];
  };

  # Docker socket access — resources widget needs Docker stats for CPU/memory/disk
  systemd.services.homepage-dashboard.serviceConfig = {
    SupplementaryGroups = [ "docker" ];
    BindReadOnlyPaths = [ "/var/run/docker.sock:/var/run/docker.sock" ];
  };

  # Reverse proxy: http://well-of-mimir/ → homepage at localhost:8082
  services.nginx.virtualHosts."default" = {
    default = true;
    listen = [
      { addr = "0.0.0.0"; port = 80; }
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
}