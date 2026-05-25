{ pkgs, inputs, ... }: {
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    extraPythonPackages = with pkgs.python312Packages; [
      sounddevice
      numpy
    ];
  };

  environment.systemPackages = with pkgs; [
    searxng
  ];
}
