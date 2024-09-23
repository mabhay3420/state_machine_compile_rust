# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # Specify the packages to include in the environment
  buildInputs = [

    # this project
    pkgs.llvm_18          # LLVM version 18
    pkgs.lldb_18          # LLDB debugger for LLVM 18
    pkgs.rustc            # Rust compiler
    pkgs.cargo            # Rust package manager
    pkgs.rust-analyzer    # Rust language server (optional)

    # general setup
    pkgs.zsh              # Zsh shell
    pkgs.vim              # Vim editor
    pkgs.which
    pkgs.openssh

    # For rustc compiler
    pkgs.libffi           # libffi library
    pkgs.libxml2


    pkgs.git
  ];

  # Define environment variables and shell configurations
  shellHook = ''
    # Set environment variables
    # export LLVM_SOURCE_DIR="/Users/mabhay/projects/llvm-project-llvmorg-18.1.8"

    # For Rust bindings

    # Use Vi keybindings in Zsh
    set -o vi

    # Preferred editor for local and remote sessions
    if [[ -n $SSH_CONNECTION ]]; then
      export EDITOR='vim'
    else
      export EDITOR='mvim'
    fi

    # Optional: Set Rust backtrace for better error messages
    # export RUST_BACKTRACE=1

    # Confirmation message
    echo "✅ Fully reproducible development environment loaded with LLVM 18, LLDB 18, Rust, Zsh, Git and Vim!"
    echo "Edit shell.nix and run `nix-shell --pure` to add new packages"
  '';
}
