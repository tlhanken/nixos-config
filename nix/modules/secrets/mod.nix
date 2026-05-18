{
  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  # Secrets
  age.secrets = {
    # nix_store_signing_key.file = ./encrypted/nix_store_signing_key.age;
    github-token.file = ./secret_files/encrypted/github-token.age;
    tailscale_key.file = ./secret_files/encrypted/tailscale_key.age;
  };
}