{ lib, ... }:
let
  port = 8082;
  hosts = [
    "localhost"
    "127.0.0.1"
    "well-of-mimir-2"
    "well-of-mimir-2.fenrir-altered.ts.net"
  ];
  allowedHosts = lib.concatStringsSep "," (map (h: "${h}:${toString port}") hosts);
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
          disk = [ "/" "/mnt/local" ];
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
              href = "http://galar.fenrir-altered.ts.net:8096";
              description = "Media server";
              icon = "jellyfin.png";
            };
          }
          {
            "Immich" = {
              href = "http://well-of-mimir-2.fenrir-altered.ts.net:2283";
              description = "Photo library";
              icon = "immich.png";
            };
          }
        ];
      }
      {
        "Tools" = [
          {
            "IT Tools" = {
              href = "http://well-of-mimir-2.fenrir-altered.ts.net:8400";
              description = "Developer utilities";
              icon = "it-tools.png";
            };
          }
        ];
      }
      {
        "AI" = [
          {
            "Open-WebUI" = {
              href = "http://well-of-mimir-2.fenrir-altered.ts.net:8080";
              description = "LLM Chat Interface";
              icon = "si-openai";
            };
          }
          {
            "ComfyUI" = {
              href = "http://well-of-mimir-2.fenrir-altered.ts.net:8188";
              description = "Stable Diffusion UI";
              icon = "si-stabilityai";
            };
          }
        ];
      }
    ];
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