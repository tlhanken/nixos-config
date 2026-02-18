{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rustc           # Rust compiler
    cargo           # Rust package manager
    rustfmt         # Rust code formatter
    rust-analyzer   # LSP server for Rust
    clippy          # Rust linter
    gcc             # C compiler and linker
    pkg-config      # Helper tool for compiling applications
    openssl         # Common dependency for Rust projects
  ];
}
