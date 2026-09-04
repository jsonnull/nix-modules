{
  pkgs,
  flakeInputs,
  ...
}:
let
  # Only forward what WiVRn's closure needs. Passing the consumer's whole
  # `pkgs.config` breaks whenever their nixpkgs gains an option this pinned
  # tree does not know (e.g. `rewriteURL`). CUDA is explicit so the NVENC
  # encoder path stays on regardless of the consumer's global `cudaSupport`.
  pkgs-master = import flakeInputs.nixpkgs-master {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      inherit (pkgs.config) allowUnfree allowUnfreePredicate;
      cudaSupport = true;
    };
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
