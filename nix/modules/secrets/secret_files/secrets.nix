let
  # Add user keys from ~/.ssh for desktop machines
  sleipnir-tlhanken = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND8Y+AKToEbNI9gyaC9yi6Y5OfZ38cP3wHYqbi2tmTu";
  tlhanken = [sleipnir-tlhanken];

  users = tlhanken;

  # Add machine keys from /etc/ssh
  sleipnir = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsMaSfMph3IA2jkIIbGycKVXsmsxRK9rkc5TwY4nA/r";
  galar = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEib+Lqe97BIJypT8LLjLwX0fn1AiFJUJazbmC0s+Aef";

  machines = [
    sleipnir
    galar
  ];

  all = users ++ machines;
in {
  # "encrypted/nix_store_signing_key.age".publicKeys = all;
  "encrypted/github-token.age".publicKeys = all;
  "encrypted/tailscale_key.age".publicKeys = all;
  "encrypted/ai-api-keys.age".publicKeys = all;
  "encrypted/searxng-secrets.age".publicKeys = all;
}