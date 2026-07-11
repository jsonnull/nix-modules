{
  lib,
  pkgs,
  flakeInputs,
  config,
  ...
}:
let
  cfg = config.tools.zed;
  pkgs-zed = import flakeInputs.nixpkgs-zed {
    system = pkgs.stdenv.hostPlatform.system;
    config = pkgs.config;
  };
  jessZed = flakeInputs.jess-lang.packages.${pkgs.stdenv.hostPlatform.system}.zed;
  json = pkgs.formats.json { };
in
{
  options.tools.zed.enable = lib.mkEnableOption "Enable Zed Editor";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs-zed.zed-editor ];

    xdg.dataFile."zed/extensions/installed/jess".source = jessZed;

    xdg.configFile."zed/themes/oxocarbon.json".source = ./themes/oxocarbon.json;

    xdg.configFile."zed/settings.json" = {
      force = true;
      source = json.generate "zed-settings.json" {
        agent_servers = {
          "codex-acp".type = "registry";
          claude.type = "registry";
        };
        project_panel.dock = "right";
        outline_panel.dock = "right";
        collaboration_panel.dock = "right";
        agent = {
          dock = "left";
          favorite_models = [ ];
          model_parameters = [ ];
        };
        git_panel.dock = "right";
        features.edit_prediction_provider = "zed";
        telemetry = {
          metrics = false;
          diagnostics = false;
        };
        vim_mode = true;
        title_bar.show_sign_in = false;
        ui_font_size = 19;
        ui_font_family = "Inter";
        agent_buffer_font_size = 19;
        buffer_font_size = 16;
        buffer_font_family = "IosevkaTerm Nerd Font Mono";
        theme = {
          mode = "system";
          light = "One Light";
          dark = "Oxocarbon - blurred";
        };
      };
    };
  };
}
