{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.tools.vscode;
in
{
  options.tools.vscode.enable = lib.mkEnableOption "Enable VSCode";

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        extensions =
          (with pkgs.vscode-extensions; [
            vscodevim.vim
            github.copilot
            github.vscode-pull-request-github
            github.vscode-github-actions

            inputs.monochrome-vscode-theme.packages.${pkgs.stdenv.hostPlatform.system}.default

            #astro-build.astro-vscode
            jnoortheen.nix-ide
            dbaeumer.vscode-eslint
            esbenp.prettier-vscode
            bradlc.vscode-tailwindcss
            ms-vsliveshare.vsliveshare
            rust-lang.rust-analyzer
            firefox-devtools.vscode-firefox-debug
          ])
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "claude-code";
              publisher = "anthropic";
              version = "2.0.74";
              sha256 = "sha256-iyWA87mJTvrqbDj5kA9k+d8l+h1KEd1j5oTQtC8a33I=";
            }
            {
              name = "gti-vscode";
              publisher = "Graphite";
              version = "0.6.1";
              sha256 = "sha256-gGpWj1iVz6nYgMk7RuYgvIf9E8Yq0lt9PZnhLLDO7So=";
            }
            {
              name = "svelte-vscode";
              publisher = "svelte";
              version = "109.1.0";
              sha256 = "sha256-ozD9k/zfklwBJtc1WdC52hgJckxBgVRmcZOwSYboACM=";
            }
          ];
        userSettings = {
          "editor.unicodeHighlight.nonBasicASCII" = false;
          "editor.largeFileOptimizations" = false;
          "editor.formatOnSave" = true;
          "editor.fontFamily" = "'IosevkaTerm Nerd Font', 'Droid Sans Mono', 'monospace', monospace";
          "terminal.integrated.fontFamily" =
            "'IosevkaTerm Nerd Font', 'Droid Sans Mono', 'monospace', monospace";
          "terminal.integrated.fontLigatures" = 14;
          "terminal.integrated.customGlyphs" = true;
          "editor.fontSize" = 14;
          "editor.fontLigatures" = true;
          #"workbench.colorTheme" = "Monochrome GitHub Dark Default"; # Theme temporarily disabled
          "workbench.tree.renderIndentGuides" = "none";
          "vim.textwidth" = 100;
          "vim.useSystemClipboard" = true;
          "vim.leader" = ",";
          "telemetry.telemetryLevel" = "off";
          "workbench.editor.tabSizing" = "fixed";
          "workbench.editor.autoLockGroups" = {
            "terminalEditor" = false;
            "workbench.editor.chatSession" = false;
            "workbench.editor.processExplorer" = false;
            "mainThreadWebview-simpleBrowser.view" = false;
            "mainThreadWebview-browserPreview" = false;
          };
          "workbench.activityBar.location" = "top";
          "workbench.sideBar.location" = "right";
          "workbench.statusBar.visible" = false;
          "[css]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[javascript]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[jsonc]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[svelte]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[typescript]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[typescriptreact]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "typescript.preferences.preferTypeOnlyAutoImports" = true;
          "editor.minimap.enabled" = false;
          "github.copilot.enable" = {
            "*" = true;
          };
          "githubPullRequests.pullBranch" = "never";
          "window.titleBarStyle" = "custom";
          "window.menuBarVisibility" = "toggle";
          "window.zoomLevel" = 1;
          "window.commandCenter" = false;
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
          "nix.serverSettinsg" = {
            "nil" = {
              "formatting" = {
                "command" = [ "nixfmt" ];
              };
            };
          };
          "extensions.autoUpdate" = false;
          "svelte.enable-ts-plugin" = true;
          "search.exclude" = {
            "**/.direnv" = true;
          };
          "claudeCode.claudeProcessWrapper" = "${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code}/bin/claude"; # TODO: reference from claude module
          "claudeCode.preferredLocation" = "panel";
        };
        keybindings = [
          {
            "key" = "ctrl+p";
            "command" = "-extension.vim_ctrl+p";
            "when" =
              "editorTextFocus && vim.active && vim.use<C-p> && !inDebugRepl || vim.active && vim.use<C-p> && !inDebugRepl && vim.mode == 'CommandlineInProgress' || vim.active && vim.use<C-p> && !inDebugRepl && vim.mode == 'SearchInProgressMode'";
          }
          {
            "key" = "ctrl+e";
            "command" = "-extension.vim_ctrl+e";
            "when" = "editorTextFocus && vim.active && vim.use<C-e> && !inDebugRepl";
          }
          {
            "key" = "ctrl+e";
            "command" = "-workbench.action.quickOpen";
          }
          {
            "key" = "ctrl+e";
            "command" = "workbench.action.findInFiles";
          }
          {
            "key" = "ctrl+shift+f";
            "command" = "-workbench.action.findInFiles";
          }
          {
            "key" = "ctrl+l";
            "command" = "-extension.vim_navigateCtrlL";
            "when" = "editorTextFocus && vim.active && vim.use<C-l> && !inDebugRepl";
          }
          {
            "key" = "ctrl+i";
            "command" = "-extension.vim_ctrl+i";
            "when" = "editorTextFocus && vim.active && vim.use<C-i> && !inDebugRepl";
          }
          {
            "key" = "ctrl+shift+e";
            "command" = "-workbench.view.explorer";
            "when" = "viewContainer.workbench.view.explorer.enabled";
          }
          {
            "key" = "ctrl+b";
            "command" = "-extension.vim_ctrl+b";
            "when" = "editorTextFocus && vim.active && vim.use<C-b> && !inDebugRepl && vim.mode != 'Insert'";
          }
          {
            "key" = "ctrl+t";
            "command" = "-extension.vim_ctrl+t";
            "when" = "editorTextFocus && vim.active && vim.use<C-t> && !inDebugRepl";
          }
        ];
      };
    };

  };
}
