# Optional GRUB+ZFS override. Normal Disko hosts rely on modules.nixos.host-shared
# for boot.loader.grub. Enable customBoot only when host-shared layout does not apply.
{
  lib,
  config,
  ...
}: let
  cfg = config.customBoot;
in {
  options = {
    customBoot.enable = lib.mkEnableOption "Override host-shared GRUB/ZFS boot settings";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      supportedFilesystems = ["zfs"];
      zfs.devNodes = "/dev/disk/by-partlabel";
      loader = {
        efi.canTouchEfiVariables = true;
        grub = {
          enable = true;
          configurationLimit = 10;
          zfsSupport = true;
          efiSupport = true;
          mirroredBoots = [
            {
              devices = ["nodev"];
              path = "/boot";
            }
          ];
        };
      };
    };
  };
}
