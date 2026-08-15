{
  system.autoUpgrade = {
    enable = false;
    flake = "github:tlhanken/nixos-config";
    flags = [
      "-L" # print build logs
    ];
    dates = "04:00";
    randomizedDelaySec = "45min";
  };
}