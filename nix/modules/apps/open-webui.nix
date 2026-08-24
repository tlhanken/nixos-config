{ pkgs, lib, config, ... }: {
  users.users.open-webui = {
    isSystemUser = true;
    uid = 983;
    group = "open-webui";
    description = "Open-WebUI service user";
  };
  users.groups.open-webui = {
    gid = 983;
  };

  services.open-webui = {
    enable = true;
    port = 8080;
    host = "0.0.0.0";
    openFirewall = true;
    stateDir = "/mnt/local/appdata/open-webui";
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      ENABLE_SIGNUP = "true";
      DEFAULT_USER_ROLE = "pending";
      OPENAI_API_BASE_URL = "https://openrouter.ai/api/v1";
    };
  };

  # Disable DynamicUser and ProtectHome to allow static appdata ownership under /mnt/local/appdata
  systemd.services.open-webui.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "open-webui";
    Group = "open-webui";
    ProtectHome = lib.mkForce false;
    WorkingDirectory = lib.mkForce "/mnt/local/appdata/open-webui";
    ReadWritePaths = [ "/mnt/local/appdata" ];
    EnvironmentFile = lib.mkIf (config.age.secrets ? ai-api-keys) config.age.secrets.ai-api-keys.path;
  };

  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata 0755 root root -"
    "Z /mnt/local/appdata/open-webui 0770 open-webui open-webui -"
  ];
}
