{ ... }: {
  # Web UI available at http://<host>:8082
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;

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
              href = "http://galar:8096";
              description = "Media server";
              icon = "jellyfin.png";
            };
          }
          {
            "Immich" = {
              href = "http://galar:2283";
              description = "Photo library";
              icon = "immich.png";
            };
          }
        ];
      }
    ];
  };
}
