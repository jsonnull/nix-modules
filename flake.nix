{
  description = "We got here through trial and error";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    # Temporary package set for pulling a newer Zed without moving the
    # system-wide nixpkgs input or the WiVRn nixpkgs-master input.
    nixpkgs-zed.url = "github:NixOS/nixpkgs/master";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Config module is on `very-refactor` (has `includes`, needed for niri 26.04 blur).
    # Packages stay on `main` so we can use niri-flake's binary cache.
    # See https://github.com/sodiboo/niri-flake/issues/1721
    niri = {
      url = "github:sodiboo/niri-flake/very-refactor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-pkgs = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stable-diffusion-webui-nix = {
      url = "github:Janrupf/stable-diffusion-webui-nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    comfyui-nix = {
      url = "github:utensils/comfyui-nix";
    };

    "monochrome-vscode-theme" = {
      url = "github:jsonnull/github-vscode-theme-monochrome/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };

    ccusage = {
      url = "github:ccusage/ccusage";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jess-lang = {
      url = "git+ssh://git@github.com/jsonnull/jess-lang.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Points to public stub by default; override with real private repo locally:
    # --override-input private git+https://github.com/jsonnull/private-config
    # --override-input private path:/home/json/private-config
    private = {
      url = "github:jsonnull/private-config-stub";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      allowedUnfree = [
        "1password"
        "1password-cli"
        "blender"
        "claude-code"
        "cuda-merged"
        "cuda_cccl"
        "cuda_cudart"
        "cuda_cuobjdump"
        "cuda_cupti"
        "cuda_cuxxfilt"
        "cuda_gdb"
        "cuda_nvcc"
        "cuda_nvdisasm"
        "cuda_nvml_dev"
        "cuda_nvprune"
        "cuda_nvrtc"
        "cuda_nvtx"
        "cuda_profiler_api"
        "cuda_sanitizer_api"
        "cudnn"
        "discord"
        "libcublas"
        "libcufft"
        "libcurand"
        "libcusolver"
        "libcusparse"
        "libnpp"
        "libnvjitlink"
        "nvidia-settings"
        "nvidia-x11"
        "obsidian"
        "slack"
        "steam"
        "steam-unwrapped"
        "vscode"
        "vscode-extension-github-copilot"
        "vscode-extension-ms-vsliveshare-vsliveshare"
      ];

      overlays = [
        inputs.niri-pkgs.overlays.niri
        inputs.stable-diffusion-webui-nix.overlays.default
      ];

      nixpkgsConfig = {
        allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) allowedUnfree;
      };
    in
    {
      nixosConfigurations.renderer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # External modules
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          inputs.niri.nixosModules.niri

          # Custom NixOS modules (explicit)
          ./modules/nixos/theme
          ./modules/nixos/printing
          ./modules/nixos/ai
          ./modules/nixos/vr
          ./modules/nixos/private

          # Host configuration
          ./hosts/renderer/nixos

          # Home-manager integration
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.json = import ./hosts/renderer/home;
            };
          }

          # Nixpkgs config
          {
            nixpkgs = {
              inherit overlays;
              config = nixpkgsConfig;
            };
          }
        ];
      };

      homeConfigurations."jsonnull@macbook" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          inherit overlays;
          config = nixpkgsConfig;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [
          inputs.sops-nix.homeManagerModules.sops
          ./hosts/macbook/home
        ];
      };

      devShells =
        let
          forAllSystems = nixpkgs.lib.genAttrs [
            "x86_64-linux"
            "aarch64-darwin"
          ];
        in
        forAllSystems (system: {
          default =
            let
              pkgs = import nixpkgs {
                inherit system overlays;
                config = nixpkgsConfig;
              };
            in
            pkgs.mkShell {
              name = "configuration";
              packages = with pkgs; [
                nil
                nixfmt
              ];
            };
        });
    };
}
