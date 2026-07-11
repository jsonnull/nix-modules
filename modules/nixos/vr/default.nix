{
  pkgs,
  flakeInputs,
  ...
}:
let
  pkgs-master = import flakeInputs.nixpkgs-master {
    system = pkgs.stdenv.hostPlatform.system;
    config = pkgs.config;
  };
in
{
  # TODO: Replace with pkgs.android-tools
  #programs.adb.enable = true;

  services.monado = {
    enable = true;
    defaultRuntime = true;
  };

  services.wivrn = {
    enable = true;
    openFirewall = true;
    package = pkgs-master.wivrn;
  };

  environment.systemPackages = with pkgs; [
    opencomposite
  ];

  home-manager.users.json = {
    xdg.configFile."openvr/openvrpaths.vrpath".text = ''
      {
        "version": 1,
        "runtime": [ "${pkgs.opencomposite}/bin/opencomposite" ]
      }
    '';
  };
}
