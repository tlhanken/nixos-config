{ pkgs, inputs, ... }:
{
  imports = [
    # Standard nixos-anywhere modules
    inputs.disko.nixosModules.disko
    inputs.nixos-facter-modules.nixosModules.facter
    {
      config.facter.reportPath =
        if builtins.pathExists ./facter.json
        then ./facter.json
        else throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./facter.json`?";
    }

    # Hardware Imports
    inputs.nixos-hardware.nixosModules.framework-12-13th-gen-intel
    # ./hardware-configuration.nix

    # Additional NixOS modules from this flake (see CLAUDE.md)
    inputs.self.modules.nixos.host-shared
    inputs.self.modules.bootstrap.bootstrap
    inputs.self.modules.bootstrapinstall.install
    inputs.self.modules.desktop.desktop
    inputs.self.modules.common.common
    inputs.self.modules.apps.steam
    inputs.self.modules.apps.rust
    inputs.self.modules.apps.searxng
    inputs.self.modules.apps.it-tools
  ];

  # Desktop session: cinnamon or gnome
  my.desktop.session = "cinnamon";

  # ============================================================================
  # Host Identity & Networking
  # ============================================================================
  networking.hostName = "sleipnir"; # Define your hostname.
  networking.hostId = "52cad215"; # Generate using `head -c 8 /etc/machine-id`
  
  # ============================================================================
  # System Basics
  # ============================================================================
  # Pin to the NixOS release when this host was first installed; do not match nixpkgs channel.
  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";
  
  # Required for nixos-anywhere
  disko.devices = import ./disk-config.nix;

  # ============================================================================
  # Boot & Filesystems
  # ============================================================================
  # Temporary fix for accelerometer data rotating desktop when in tent mode on framework 12
  boot.initrd.kernelModules = [ "pinctrl_tigerlake" ];
  boot.kernelModules = [ "thunderbolt" ];

  # ============================================================================
  # Hardware & Kernel
  # ============================================================================
  services.hardware.bolt.enable = true;

  # Firmware and bootloader
  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
    uefiCapsuleSettings.DisableCapsuleUpdateOnDisk = true;
  };

  # Razer Support
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [ "tlhanken" ];

  # Sensors & Rotation
  hardware.sensor.iio.enable = true;

  # ============================================================================
  # Host Features
  # ============================================================================
  # Enable Cross-Device Mounts
  my.mounts.media = {
    enable = true;
    writable = true;
  };
  my.mounts.vault.enable = true;
  # my.mounts.backup.enable = true;
  my.mounts.legacyPaths.enable = true;
  my.mounts.ai = {
    enable = true;
    writable = true;
  };

  # ============================================================================
  # Users & Environment
  # ============================================================================
  users.users.tlhanken = {
    isNormalUser = true;
    description = "Trevor Hanken";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    hashedPassword = "$6$QwxrgyqftaIVyPRS$1BcH0tM8DbFEzzvYcsz7AeQvZImxUUxwyj0SVYCpvZZTZ1BtKjlrUTg3ydGIX9doSKCOw/M91Y11ZtAaQZuPD1"; # Hash of a password can be found with "mkpasswd -m sha-512"
  };

  environment.systemPackages = [ pkgs.polychromatic ];

  # ============================================================================
  # Custom Services
  # ============================================================================
  # Rotation fix script
  systemd.user.services.auto-rotate = {
    description = "Auto-rotate screen based on accelerometer";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    path = [ pkgs.iio-sensor-proxy pkgs.xorg.xrandr pkgs.gawk pkgs.coreutils pkgs.xorg.xinput ];
    script = ''
      # Find the eDP display (internal display)
      DISPLAY_NAME=$(xrandr | grep " connected" | grep "eDP" | cut -d " " -f1)
      
      if [ -z "$DISPLAY_NAME" ]; then
        echo "No eDP display found, exiting."
        exit 1
      fi

      # Find Touchscreen ID (Framework 12 specific or generic)
      # We use a pattern match for common touchscreens
      TOUCH_ID=$(xinput list | grep -i "touch" | grep -v "Touchpad" | grep -o 'id=[0-9]*' | cut -d= -f2 | head -n 1)

      monitor-sensor --accel | while read -r line; do
        if echo "$line" | grep -q "normal"; then
          xrandr --output "$DISPLAY_NAME" --rotate normal
          [ -n "$TOUCH_ID" ] && xinput set-prop "$TOUCH_ID" --type=float "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1
        elif echo "$line" | grep -q "bottom-up"; then
          xrandr --output "$DISPLAY_NAME" --rotate inverted
          [ -n "$TOUCH_ID" ] && xinput set-prop "$TOUCH_ID" --type=float "Coordinate Transformation Matrix" -1 0 1 0 -1 1 0 0 1
        elif echo "$line" | grep -q "right-up"; then
          xrandr --output "$DISPLAY_NAME" --rotate right
          [ -n "$TOUCH_ID" ] && xinput set-prop "$TOUCH_ID" --type=float "Coordinate Transformation Matrix" 0 1 0 -1 0 1 0 0 1
        elif echo "$line" | grep -q "left-up"; then
          xrandr --output "$DISPLAY_NAME" --rotate left
          [ -n "$TOUCH_ID" ] && xinput set-prop "$TOUCH_ID" --type=float "Coordinate Transformation Matrix" 0 -1 1 1 0 0 0 0 1
        fi
      done
    '';
    serviceConfig = {
      Restart = "always";
      RestartSec = "500ms";
    };
  };
}
