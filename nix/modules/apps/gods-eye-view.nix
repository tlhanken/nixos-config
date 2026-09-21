{ pkgs, lib, config, ... }:
let
  net = import ../../lib/network.nix;
  gods-eye-view-pkg = pkgs.buildNpmPackage {
    pname = "gods-eye-view";
    version = "0.1.1";

    src = pkgs.fetchFromGitHub {
      owner = "bilawalsidhu";
      repo = "gods-eye-view";
      rev = "de2a41927b54b3776615a5c0ad13b133f6e42f76";
      hash = "sha256-MVWXcFtrFhYI6YDK0NVOfaFozCDp4Tsm5WLBAnh3yC8=";
    };

    nodejs = pkgs.nodejs_24;

    npmDepsHash = "sha256-Lh2vx9m0jsT1UMqgQBU0dfVO8X+/FktRRZCmpPhHVIw=";

    env = {
      PUPPETEER_SKIP_DOWNLOAD = "true";
    };

    dontNpmBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/gods-eye-view
      cp -r . $out/share/gods-eye-view/
      runHook postInstall
    '';

    meta = with lib; {
      description = "A real-time intelligence console for planet Earth";
      homepage = "https://github.com/bilawalsidhu/gods-eye-view";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };
in
{
  # Service User & Group
  users.users.gods-eye-view = {
    isSystemUser = true;
    group = "gods-eye-view";
    description = "God's Eye View service user";
  };
  users.groups.gods-eye-view = { };

  # Systemd Service — Purely stateless in /nix/store + RAM tmpfs
  systemd.services.gods-eye-view = {
    description = "God's Eye View Real-time 3D Earth Console";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "gods-eye-view";
      Group = "gods-eye-view";
      WorkingDirectory = "/run/gods-eye-view";
      RuntimeDirectory = "gods-eye-view";

      ExecStartPre = pkgs.writeShellScript "gods-eye-view-setup" ''
        ${pkgs.findutils}/bin/find /run/gods-eye-view -mindepth 1 -delete
        ${pkgs.coreutils}/bin/cp -a ${gods-eye-view-pkg}/share/gods-eye-view/. /run/gods-eye-view/
        ${pkgs.coreutils}/bin/chmod -R u+w /run/gods-eye-view
      '';

      ExecStart = "${pkgs.nodejs_24}/bin/node ./node_modules/vite/bin/vite.js --host 127.0.0.1 --port 4174";
      Restart = "always";
      RestartSec = "5s";

      Environment = [
        "NODE_ENV=production"
        "PUPPETEER_SKIP_DOWNLOAD=true"
        "HOME=/run/gods-eye-view"
        "HOST=127.0.0.1"
        "PORT=4174"
      ];
      EnvironmentFile = lib.mkIf (config.age.secrets ? gods-eye-view-secrets) config.age.secrets.gods-eye-view-secrets.path;

      # Strict Sandboxing & Kernel Isolation
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
      RestrictSUIDSGID = true;
      ReadWritePaths = [ "/run/gods-eye-view" ];
    };
  };

  # Reverse Proxy: Nginx terminates port 4173 and forwards to internal Vite on 127.0.0.1:4174
  services.nginx.virtualHosts."gods-eye-view" = {
    listen = [{ addr = "0.0.0.0"; port = 4173; ssl = false; }];
    serverAliases = [
      net.hosts.well-of-mimir-2.magicDns
      "well-of-mimir-2"
      "localhost"
      "127.0.0.1"
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:4174";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host localhost;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
      '';
    };
  };

  # Open port 4173 on the firewall
  networking.firewall.allowedTCPPorts = [ 4173 ];
}
