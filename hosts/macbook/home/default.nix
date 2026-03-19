{
  config,
  pkgs,
  lib,
  ...
}:

let
  username = "jsonnull";
  homeDir = "/Users/jsonnull";
in
{
  imports = [
    # Home modules (explicit)
    ../../../modules/home/theme
    ../../../modules/home/tools/development
    ../../../modules/home/tools/ghostty
    ../../../modules/home/tools/nixcats
    ../../../modules/home/tools/obsidian
    ../../../modules/home/term
    ../../../modules/home/private
  ];

  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = username;
  home.homeDirectory = homeDir;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Set theme directly (no NixOS to inherit from)
  homeTheme.theme = "default-dark";

  # Enable app modules
  #apps.chrome.enable = true;
  #apps.discord.enable = true;
  #apps.slack.enable = true;

  # Enable tool modules
  tools.dev-general.enable = true;
  tools.ghostty.enable = true;
  tools.nixcats.enable = true;
  tools.obsidian.enable = true;
  #xdg.configFile.alacritty.source = lib.mkForce (../../config/alacritty-macbook);

  home.packages = with pkgs; [
    dockutil
    tailscale
    (nerd-fonts.iosevka)
  ];

  home.activation.dock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.dockutil}/bin/dockutil --remove all --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Firefox.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "$HOME/.nix-profile/Applications/Alacritty.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Music.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Slack.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "$HOME/.nix-profile/Applications/Visual Studio Code.app" --no-restart
  '';

  programs.zsh.initExtraFirst = ''
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  '';
}
