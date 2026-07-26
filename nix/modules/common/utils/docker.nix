{
  lib,
  pkgs,
  config,
  ...
}: let
  zfsRoot = config.boot.supportedFilesystems.zfs or false;
in {
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29 or pkgs.docker;
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
