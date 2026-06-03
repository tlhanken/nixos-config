{
  lib,
  config,
  ...
}: let
  zfsRoot = config.boot.supportedFilesystems.zfs or false;
in {
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = false;
      setSocketVariable = true;
    };
    storageDriver = lib.mkIf zfsRoot "zfs";
    autoPrune = {
      enable = true;
      flags = [];
    };
  };
}
