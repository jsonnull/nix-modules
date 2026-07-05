{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.tools.kitty;
in
{
  options.tools.kitty.enable = lib.mkEnableOption "Enable Kitty";

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;

      settings = {
        shell = "${pkgs.zsh}/bin/zsh";

        # Font
        font_family = "IosevkaTerm Nerd Font";
        font_size = 13;

        # Window
        window_padding_width = 8;
        background_blur = 1;
        background_opacity = "0.8";
        hide_window_decorations = "yes";
        tab_bar_style = "hidden";
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        visual_bell_duration = 0;

        # Oxocarbon colors
        background = "#161616";
        foreground = "#f2f4f8";
        cursor = "#f2f4f8";
        selection_background = "#393939";
        selection_foreground = "#f2f4f8";

        color0 = "#161616";
        color1 = "#ee5396";
        color2 = "#42be65";
        color3 = "#ff7eb6";
        color4 = "#78a9ff";
        color5 = "#be95ff";
        color6 = "#3ddbd9";
        color7 = "#dde1e6";
        color8 = "#525252";
        color9 = "#ee5396";
        color10 = "#42be65";
        color11 = "#ff7eb6";
        color12 = "#78a9ff";
        color13 = "#be95ff";
        color14 = "#3ddbd9";
        color15 = "#f2f4f8";
      };

      extraConfig = ''
        modify_font cell_height 105%
        modify_font cell_width 90%
        text_composition_strategy legacy
      '';
    };
  };
}
