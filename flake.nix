{
  description = "my minimal flake";
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # nixos-22.11

    # Manages configs links things into your home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Controls system level software and settings including fonts
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs: {
    darwinConfigurations.Demos-Virtual-Machine = inputs.darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import inputs.nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
      modules = [
        ({pkgs, ...}: {
          # here go the darwin preferences and config items
          programs.zsh.enable = true;
          environment.shells = [pkgs.bash pkgs.zsh];
          environment.loginShell = pkgs.zsh;
          environment.systemPackages = [
            pkgs.coreutils
          ];
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';
          system.keyboard.enableKeyMapping = true;
          system.keyboard.remapCapsLockToEscape = true;
          fonts.fontDir.enable = true; # DANGER
          fonts.fonts = [(pkgs.nerdfonts.override {fonts = ["Meslo"];})];
          services.nix-daemon.enable = true;

          # system.defaults.finder.AppleShowAllExtensions = true;
          # system.defaults.finder._FXShowPosixPathInTitle = true;
          # system.defaults.dock.autohide = true;
          # system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;

          system.defaults.NSGlobalDomain.InitialKeyRepeat = 14;
          system.defaults.NSGlobalDomain.KeyRepeat = 1;

          # backwards compat; don't change
          system.stateVersion = 4;
        })
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.rst.imports = [
              ({pkgs, ...}: {
                # Don't change this when you change package input. Leave it alone.
                home.stateVersion = "22.11";
                # specify my home-manager configs
                home.packages = with pkgs; [
                  ripgrep
                  fd
                  curl
                  less
                  fmt
                  nixpkgs-fmt
                  alejandra
                  shfmt
                  shellcheck
                ];
                home.sessionVariables = {
                  PAGER = "less";
                  CLICLOLOR = 1;
                  EDITOR = "code";
                };
                programs.bat.enable = true;
                programs.bat.config.theme = "TwoDark";
                programs.fzf.enable = true;
                programs.fzf.enableZshIntegration = true;
                programs.exa.enable = true;
                programs.git.enable = true;
                programs.zsh.enable = true;
                programs.zsh.enableCompletion = true;
                programs.zsh.enableAutosuggestions = true;
                programs.zsh.enableSyntaxHighlighting = true;
                programs.zsh.shellAliases = {ls = "ls --color=auto -F";};

                programs.vscode = {
                  enable = true;
                  package = pkgs.vscode;
                  userSettings = import ./vscode_settings.nix {inherit pkgs;}.getUserSettings;
                  extensions =
                    with pkgs.vscode-extensions; [
                      ms-azuretools.vscode-docker
                      skellock.just
                      jnoortheen.nix-ide
                      foxundermoon.shell-format
                      kamadorueda.alejandra
                      timonwong.shellcheck
                      mhutchie.git-graph
                    ]
                    # TODO: get this to work
                    # ++ (with pkgs.nur.repos.slaier.vscode-extensions; [
                    #  ms-vscode-remote.remote-containers
                    # ])
                    ;
                };

                # programs.starship.enable = true;
                # programs.starship.enableZshIntegration = true;
                # programs.alacritty = {
                # enable = true;
                # settings.font.normal.family = "MesloLGS Nerd Font Mono";
                # settings.font.size = 16;
                # };
              })
              ./vscode
            ];
          };
        }
      ];
    };
  };
}
