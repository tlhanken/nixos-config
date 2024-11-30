# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}:
with config; {
  imports = [
    # Include the results of the hardware scan.
    # TODO
    # ./hardware-configuration.nix
  ];

  networking.hostName = "well-of-nix"; # Define your hostname.
  networking.hostId = "5433dcd9"; # Generate using `head -c 8 /etc/machine-id`

  # TODO
  # disko.devices = import ./devices.nix;
  customBoot.enable = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
