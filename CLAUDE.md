# nix-modules

Public NixOS and Home Manager modules published as a flake. This repo contains
no hosts and no composition root — the private configuration repo at
`~/configuration` consumes these modules as its `nix-modules` flake input.

## Structure

- `modules/nixos/` - NixOS modules
- `modules/home/` - Home Manager modules
- `packages/` - Custom packages

## Conventions

- Modules read this flake's inputs via the `flakeInputs` module argument
  (bound in `flake.nix`), never via `inputs` — `inputs` belongs to consumers.
- Never use module args (like `flakeInputs`) inside `imports`; hoist external
  module imports into the flake-level wrapper in `flake.nix`.
- Nothing private goes here: no hostnames, network topology, hardware IDs, or
  secrets. Those live in the private configuration repo.
