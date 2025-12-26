let
  # Add user keys from ~/.ssh for desktop machines
  sleipnir-tlhanken = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND8Y+AKToEbNI9gyaC9yi6Y5OfZ38cP3wHYqbi2tmTu";
  tlhanken = [sleipnir-tlhanken];

  users = tlhanken;

  # Add machine keys from /etc/ssh
  sleipnir = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsMaSfMph3IA2jkIIbGycKVXsmsxRK9rkc5TwY4nA/r";

  machines = [
    sleipnir
  ];

  all = users ++ machines;
in {
  # "encrypted/nix_store_signing_key.age".publicKeys = all;
  # "encrypted/github_pat.age".publicKeys = all;
  "encrypted/tailscale_key.age".publicKeys = all;
}