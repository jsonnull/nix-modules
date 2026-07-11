{
  description = "Public NixOS and Home Manager modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    # Temporary package set for pulling a newer Zed without moving the
    # module-wide nixpkgs input or the WiVRn nixpkgs-master input.
    nixpkgs-zed.url = "github:NixOS/nixpkgs/master";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";

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
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      # Binds this flake's own inputs to the `flakeInputs` module argument so
      # consumers never have to redeclare them. Uses `key` so the module system
      # deduplicates it when several exported modules are imported together.
      argsModule = {
        _file = "nix-modules/flake.nix";
        key = "nix-modules#flakeInputs";
        config._module.args.flakeInputs = inputs;
      };

      # The wrapper key must differ from the wrapped path's own module key,
      # or the module system deduplicates the real module away.
      wrap = path: {
        _file = toString path;
        key = "${toString path}#nix-modules-wrapper";
        imports = [
          argsModule
          path
        ];
      };

      mapModules = builtins.mapAttrs (_: wrap);

      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    in
    {
      nixosModules = mapModules {
        theme = ./modules/nixos/theme;
        printing = ./modules/nixos/printing;
        ai = ./modules/nixos/ai;
        vr = ./modules/nixos/vr;
      };

      homeManagerModules =
        mapModules {
          theme = ./modules/home/theme;
          term = ./modules/home/term;

          chrome = ./modules/home/apps/chrome;
          discord = ./modules/home/apps/discord;
          keepassxc = ./modules/home/apps/keepassxc;
          slack = ./modules/home/apps/slack;

          claude = ./modules/home/tools/claude;
          codex = ./modules/home/tools/codex;
          development = ./modules/home/tools/development;
          gamedev = ./modules/home/tools/gamedev;
          kitty = ./modules/home/tools/kitty;
          obsidian = ./modules/home/tools/obsidian;
          vscode = ./modules/home/tools/vscode;
          waybar = ./modules/home/tools/waybar;
          zed = ./modules/home/tools/zed;
          zellij = ./modules/home/tools/zellij;
        }
        // {
          # nixCats' home module has to be imported at flake level: module
          # arguments like `flakeInputs` can't be used inside `imports`.
          nixcats = {
            _file = "nix-modules/flake.nix#nixcats";
            key = "${toString ./modules/home/tools/nixcats}#nix-modules-wrapper";
            imports = [
              inputs.nixCats.homeModule
              argsModule
              ./modules/home/tools/nixcats
            ];
          };
        };

      overlays = {
        stable-diffusion = inputs.stable-diffusion-webui-nix.overlays.default;
      };

      lib = {
        # Unfree package names required by the modules in this flake, for use
        # in the consumer's `allowUnfreePredicate`.
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
      };

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          claude-notifications-go = pkgs.callPackage ./packages/claude-notifications-go { };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            name = "nix-modules";
            packages = with pkgs; [
              nil
              nixfmt
            ];
          };
        }
      );
    };
}
