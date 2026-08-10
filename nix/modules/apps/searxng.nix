{ pkgs, ... }: {
  services.searx = {
    enable = true;
    package = pkgs.searxng;

    # The secret key placeholder is substituted at runtime from environmentFile.
    # Variable name must be SEARX_SECRET_KEY (what the NixOS module expects).
    settings = {
      server = {
        port = 8888;
        bind_address = "0.0.0.0";
        secret_key = "$SEARX_SECRET_KEY";
      };
      search = {
        safe_search = 0;
        default_lang = "en";
        formats = [ "html" "json" ];
      };
      # Curated engine list for agent research use
      engines = [
        { name = "google"; engine = "google"; disabled = false; }
        { name = "duckduckgo"; engine = "duckduckgo"; disabled = false; }
        { name = "wikipedia"; engine = "wikipedia"; disabled = false; }
        { name = "github"; engine = "github"; disabled = false; }
        { name = "stackoverflow"; engine = "stackoverflow web"; disabled = false; }
        { name = "arxiv"; engine = "arxiv"; disabled = false; }
      ];
    };

    # Provide SEARX_SECRET_KEY via agenix-managed env file.
    # Generate a key with: openssl rand -hex 32
    # Add to secret with: just edit-secret searxng-secrets
    # File contents should be:  SEARX_SECRET_KEY=<hex string>
    environmentFile = "/run/agenix/searxng-secrets";
  };

  networking.firewall.allowedTCPPorts = [ 8888 ];
}
