{
  users.users.tlhanken = {
    isNormalUser = true;
    description = "Trevor Hanken";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    # Create with mkpasswd -m sha-512
    hashedPassword = "$6$aVX13r8lw5yvxWJZ$TrXrqKub2dJArKGyZ75l5AQC.yIh8ysgigZniYT.ZkvQRvjgb45oFNUnFIUd5xTfE0JXzFzPHwMWdJcdth9Tj1";
  };
}
