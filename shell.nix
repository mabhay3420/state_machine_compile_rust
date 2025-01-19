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
    pkgs.clippy           # Rust linter

    # general setup
    pkgs.zsh              # Zsh shell
    pkgs.vim              # Vim editor
    pkgs.coreutils        # the basic utilities - cat, ls, less etc.
    pkgs.which
    pkgs.openssh          # for ssh
    pkgs.less             # git uses it :shock: and its not part of coreutils

    # For rustc compiler
    pkgs.libffi           # libffi library - rust uses ffi? or rustc does? I dunno
    pkgs.libxml2


    # version control baby
    pkgs.git
  ];
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

  # Define environment variables and shell configurations
  shellHook = ''
    # Set environment variables

    echo ">> Going to use vim in shell - change this if you don't like that"
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
    echo "🛠️  Edit 'shell.nix' and run 'nix-shell --pure' to add new packages"
    echo "✅ Fully reproducible development environment loaded with LLVM 18, LLDB 18, Rust, Git and Vim!"
  '';

}
