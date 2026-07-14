# Minimal packages and Nix flake support for nixos-anywhere / first boot.
# Shared policy (caches, nh, SSH, boot, secrets) lives in modules.nixos.host-shared.
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    curl
    git
    nano
  ];
  environment.variables.EDITOR = "nano";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
