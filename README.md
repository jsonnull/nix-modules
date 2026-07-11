# nix-modules

Public NixOS and Home Manager modules I use

## Outputs

- `nixosModules.*`
- `homeManagerModules.*`
- `overlays.stable-diffusion`
- `packages.claude-notifications-go`
- `lib.allowedUnfree` — unfree requirements for consumer's
  `allowUnfreePredicate`

Modules receive this flake's own inputs through the `flakeInputs` module
argument (bound in `flake.nix`), so consumers don't need to redeclare any of
them and are free to use `specialArgs.inputs` for their own purposes.

## Usage

```nix
{
  inputs.nix-modules.url = "github:jsonnull/nix-modules";

  # In a NixOS configuration:
  #   modules = [ inputs.nix-modules.nixosModules.theme ... ];
  # In a Home Manager configuration:
  #   imports = [ inputs.nix-modules.homeManagerModules.kitty ... ];
}
```

Check modules for an enable option (`tools.<name>.enable`,
`apps.<name>.enable`, `theme.enable`, ...). Imported modules with this option
may be inert until enabled.
