{config, pkgs, lib, ...}: let
  ai = config.my.mounts.ai;
in {
  users.users.ollama = {
    isSystemUser = true;
    uid = 986;
    description = "Ollama";
    extraGroups = lib.optionals ai.enable ["ai"];
  };

  services.ollama = {
    enable = true;
    # App metadata only; weights live on /mnt/ai when enabled.
    home = "/mnt/local/appdata/ollama";
    user = "ollama";
    models = lib.mkIf ai.enable "${ai.mountPoint}/models/llm";
  };

  environment.variables = lib.mkIf ai.enable {
    OLLAMA_MODELS = "${ai.mountPoint}/models/llm";
  };

  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata       0755 root   root   -"
    "d /mnt/local/appdata/ollama 0770 ollama ollama -"
  ];
}
