{ pkgs, ... }:
let
  port = 3002;

  composeConfig = {
    name = "firecrawl";

    networks = {
      firecrawl-network = {
        driver = "bridge";
      };
    };

    services = {
      playwright-service = {
        image = "ghcr.io/firecrawl/playwright-service:latest";
        environment = {
          PORT = "3000";
          BLOCK_MEDIA = "true";
          MAX_CONCURRENT_PAGES = "10";
        };
        networks = [ "firecrawl-network" ];
        security_opt = [ "no-new-privileges:true" ];
        cap_drop = [ "ALL" ];
        restart = "always";
        tmpfs = [
          "/tmp/.cache:noexec,nosuid,size=1g"
        ];
      };

      redis = {
        image = "redis:alpine";
        command = "redis-server --bind 0.0.0.0 --appendonly yes";
        networks = [ "firecrawl-network" ];
        volumes = [
          "/mnt/local/appdata/firecrawl/data/redis:/data"
        ];
        restart = "always";
      };

      rabbitmq = {
        image = "rabbitmq:3-management";
        command = "rabbitmq-server";
        networks = [ "firecrawl-network" ];
        volumes = [
          "/mnt/local/appdata/firecrawl/data/rabbitmq:/var/lib/rabbitmq"
        ];
        healthcheck = {
          test = [ "CMD" "rabbitmq-diagnostics" "-q" "check_running" ];
          interval = "5s";
          timeout = "5s";
          retries = 5;
          start_period = "5s";
        };
        restart = "always";
      };

      nuq-postgres = {
        image = "ghcr.io/firecrawl/nuq-postgres:latest";
        environment = {
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_DB = "postgres";
        };
        networks = [ "firecrawl-network" ];
        volumes = [
          "/mnt/local/appdata/firecrawl/data/postgres:/var/lib/postgresql/data"
        ];
        healthcheck = {
          test = [ "CMD-SHELL" "pg_isready -U postgres -d postgres" ];
          interval = "5s";
          timeout = "5s";
          retries = 5;
          start_period = "5s";
        };
        restart = "always";
      };

      api = {
        image = "ghcr.io/firecrawl/firecrawl:latest";
        command = "node dist/src/harness.js --start-docker";
        environment = {
          HOST = "0.0.0.0";
          PORT = "3002";
          INTERNAL_PORT = "3002";
          REDIS_URL = "redis://redis:6379";
          REDIS_RATE_LIMIT_URL = "redis://redis:6379";
          PLAYWRIGHT_MICROSERVICE_URL = "http://playwright-service:3000/scrape";
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_DB = "postgres";
          POSTGRES_HOST = "nuq-postgres";
          POSTGRES_PORT = "5432";
          USE_DB_AUTHENTICATION = "false";
          NUM_WORKERS_PER_QUEUE = "8";
          CRAWL_CONCURRENT_REQUESTS = "10";
          MAX_CONCURRENT_JOBS = "5";
          BROWSER_POOL_SIZE = "5";
          EXTRACT_WORKER_PORT = "3004";
          WORKER_PORT = "3005";
          NUQ_RABBITMQ_URL = "amqp://rabbitmq:5672";
          HARNESS_STARTUP_TIMEOUT_MS = "60000";
          ENV = "local";
          OLLAMA_BASE_URL = "http://host.docker.internal:11434";
        };
        extra_hosts = [
          "host.docker.internal:host-gateway"
        ];
        depends_on = {
          redis = {
            condition = "service_started";
          };
          playwright-service = {
            condition = "service_started";
          };
          rabbitmq = {
            condition = "service_healthy";
          };
          nuq-postgres = {
            condition = "service_healthy";
          };
        };
        ports = [
          "0.0.0.0:3002:3002"
        ];
        networks = [ "firecrawl-network" ];
        restart = "always";
      };
    };
  };

  composeFile = pkgs.writeText "firecrawl-compose.json" (builtins.toJSON composeConfig);
in
{
  # Ensure persistent directories exist for stack data
  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata                         0755 root root -"
    "d /mnt/local/appdata/firecrawl                0755 root root -"
    "d /mnt/local/appdata/firecrawl/data           0755 root root -"
    "d /mnt/local/appdata/firecrawl/data/postgres  0755 root root -"
    "d /mnt/local/appdata/firecrawl/data/redis     0755 root root -"
    "d /mnt/local/appdata/firecrawl/data/rabbitmq  0755 root root -"
  ];

  # Systemd service managing the Firecrawl Docker Compose stack
  systemd.services.firecrawl = {
    description = "Firecrawl Web Scraping and Crawling Stack";
    after = [ "docker.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      (pkgs.docker_29 or pkgs.docker)
      pkgs.docker-compose
    ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "10s";
      TimeoutStartSec = "300s";
      TimeoutStopSec = "60s";
      WorkingDirectory = "/mnt/local/appdata/firecrawl";
      ExecStartPre = pkgs.writeShellScript "firecrawl-prestart" ''
        ${pkgs.docker-compose}/bin/docker-compose -f ${composeFile} down --remove-orphans || true
      '';
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${composeFile} up --remove-orphans";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f ${composeFile} down";
    };
  };

  # Open port 3002 on the firewall for Tailscale and fleet access
  networking.firewall.allowedTCPPorts = [ port ];
}
