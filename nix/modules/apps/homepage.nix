{ lib, ... }:
let
  port = 8082;
  hosts = [
    "localhost"
    "127.0.0.1"
    "galar"
    "galar.fenrir-altered.ts.net"
    # Add any host that should be able to serve the homepage here
  ];
  allowedHosts = lib.concatStringsSep "," (map (h: "${h}:${toString port}") hosts);
in
{
  # Web UI available at http://<host>:8082
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
              href = "http://galar.fenrir-altered.ts.net:2283";
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
              href = "http://sleipnir.fenrir-altered.ts.net:8400";
              description = "Developer utilities";
              icon = "it-tools.png";
            };
          }
        ];
      }
    ];
  };
}
