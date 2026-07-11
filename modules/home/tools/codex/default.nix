{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:

let
  cfg = config.tools.codex;
  llm-agents = flakeInputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.tools.codex = {
    enable = lib.mkEnableOption "Enable Codex CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ llm-agents.codex ];
  };
}
