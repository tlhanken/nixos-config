{
  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  # Secrets
  age.secrets = {
    # github_pat.file = ./encrypted/github_pat.age;
    # nix_store_signing_key.file = ./encrypted/nix_store_signing_key.age;
    tailscale_key.file = ./secret_files/encrypted/tailscale_key.age;
  };
}