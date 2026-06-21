{
  lib,
  pkgs,
  config,
  ...
}:
{
  home.packages = [
    pkgs.repomix
    pkgs.ripgrep
    pkgs.nodejs_26
    pkgs.typescript-language-server
    pkgs.vscode-json-languageserver
    pkgs.yaml-language-server
    pkgs.gh
    pkgs.rust-analyzer
    pkgs.nil
    pkgs.nixfmt
    pkgs.wget
    pkgs._7zz
    pkgs.unzip
    pkgs.unar
    pkgs.nb
  ];

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    EDITOR = "nvim";
    TMUX_OVERRIDE_TERM = "false";
    NB_BROWSER = "xdg-open";
  };

  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#006800"; # Using modus green for better visibility
    };
    syntaxHighlighting.enable = true;
    history.size = 1000000;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "z"
        "vi-mode"
      ];
    };
    shellAliases = {
      vim = "nvim";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      nix_shell.format = "via [$symbol$name](bold blue)";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    signing.format = null;
    ignores = [
      ".direnv"
      ".claude/settings.local.json"
    ];
    settings = {
      core.autocrlf = "input";
      core.whitespace = "cr-at-eol";
      user.name = "Jason Nall";
      user.email = "json${"null"}${"@"}${"g"}${"ma"}${"il"}${"."}${"com"}";
      push.default = "current";
      init.defaultBranch = "main";
    };
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    extraOptions = [
      "--group-directories-first"
    ];
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    settings = {
      manager = {
        ratio = [
          0
          2
          3
        ]; # hide parent, current:preview = 2:3
      };
      preview = {
        max_width = 6144;
        max_height = 6144;
      };
      opener = {
        video = [
          {
            run = ''vlc "$@"'';
            orphan = true;
            desc = "VLC";
          }
        ];
      };
      open = {
        prepend_rules = [
          {
            mime = "video/*";
            use = "video";
          }
        ];
      };
    };
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    prefix = "C-a";
    # https://github.com/nix-community/home-manager/issues/5952
    sensibleOnTop = false;
    shell = "${pkgs.zsh}/bin/zsh";
    extraConfig = ''
      set -g status-style bg=#161616,fg=#525252

      set -g default-terminal 'xterm-256color'
      set -as terminal-overrides ',xterm*:Tc:sitm=\E[3m'

      #set -g status-left-length 100
      #set -g status-right-length 100
      set -g status-left "[#S] "
    '';
    # TODO: Consolidate; I'm pretty sure this does the same thing as `set g default-terminal` above.
    terminal = "xterm-256color";
  };
}
