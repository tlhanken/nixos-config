{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    (inputs.hermes-agent.packages.${pkgs.system}.default.override {
      extraPythonPackages = with pkgs.python312Packages; [
        sounddevice
        numpy
      ];
    })
    searxng
  ];
}
