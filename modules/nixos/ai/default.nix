{
  pkgs,
  flakeInputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  llm-agents = flakeInputs.llm-agents.packages.${system};
  comfy-ui-cuda = flakeInputs.comfyui-nix.packages.${system}.cuda;
in
{
  networking.firewall.allowedTCPPorts = [
    # sillytavern
    8000
    # delailah
    3000
    5173
  ];

  environment.systemPackages = [
    pkgs.sillytavern
    # pkgs.stable-diffusion-webui.forge.cuda # disabled: sphinx 9.1 incompatible with python 3.11
    llm-agents.qwen-code
    comfy-ui-cuda
  ];
}
