{
  lib,
  pkgs,
  config,
  flakeInputs,
  ...
}:
let
  cfg = config.tools.nixcats;
in
{
  # nixCats' home module is imported by the flake-level wrapper (see flake.nix):
  # module args like flakeInputs can't be used inside `imports`.
  options.tools.nixcats.enable = lib.mkEnableOption "Enable nixCats";

  config = lib.mkIf cfg.enable {
    nixCats = {
      enable = true;
      packageNames = [ "nvim" ];
      luaPath = "${./.}";

      categoryDefinitions.replace =
        { pkgs, ... }:
        {
          lspsAndRuntimeDeps = {
            general = with pkgs; [
              ripgrep
              fd
            ];
            lsp = with pkgs; [
              bash-language-server
              vscode-langservers-extracted # cssls, html, jsonls, eslint
              lua-language-server
              nil # Nix LSP
              svelte-language-server
              yaml-language-server
              rust-analyzer
              # Formatters
              nixfmt
              stylua
              prettierd
              # Linters
              shellcheck
              statix
            ];
          };

          # Plugins that load immediately at startup
          startupPlugins = {
            general = with pkgs.vimPlugins; [
              # Core dependencies
              plenary-nvim
              nvim-web-devicons

              # Lazy loader
              lze

              # UI (always visible)
              lualine-nvim
              bufferline-nvim
              vim-startify

              # Colorscheme
              oxocarbon-nvim

              # Git (signs in gutter)
              gitsigns-nvim

              # Breadcrumbs
              dropbar-nvim

              # Snacks (has startup features)
              snacks-nvim

              # Session management (needs early load)
              auto-session

              # Treesitter (startup for folding/highlighting)
              (nvim-treesitter.withPlugins (p: [
                p.bash
                p.javascript
                p.json
                p.lua
                p.make
                p.markdown
                p.nix
                p.regex
                p.svelte
                p.toml
                p.tsx
                p.typescript
                p.vim
                p.vimdoc
                p.xml
                p.yaml
              ]))
              flakeInputs.jess-lang.packages.${pkgs.stdenv.hostPlatform.system}.nvim
              nvim-treesitter-textobjects
            ];
          };

          # Plugins that load on-demand
          optionalPlugins = {
            general = with pkgs.vimPlugins; [
              # File explorer
              nvim-tree-lua

              # Editing
              mini-nvim

              # Utilities
              which-key-nvim
              bufdelete-nvim

              # LSP
              nvim-lspconfig
              typescript-tools-nvim

              # Formatting
              conform-nvim

              # Linting
              nvim-lint

              # Completion
              blink-cmp
              friendly-snippets

              # GitHub
              octo-nvim
            ];
          };
        };

      packageDefinitions.replace = {
        nvim =
          { pkgs, ... }:
          {
            settings = {
              wrapRc = true;
              aliases = {
                vim = true;
                vimdiff = true;
                vi = true;
              };
            };
            categories = {
              general = true;
              lsp = true;
            };
          };
      };
    };
  };
}
