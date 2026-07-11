{
  lib,
  pkgs,
  config,
  flakeInputs,
  ...
}:
let
  cfg = config.tools.dev-general;
  caRoot = "${config.home.homeDirectory}/.local/share/mkcert";
  llm-agents = flakeInputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.tools.dev-general.enable = lib.mkEnableOption "Enable general development tools";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gh
      mkcert
      nssTools
      llm-agents.claude-code
    ];

    home.sessionVariables = {
      CAROOT = caRoot;
      NODE_EXTRA_CA_CERTS = "${caRoot}/rootCA.pem";
    };

    home.activation.installMkcertRoot = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export CAROOT="${caRoot}"
      export PATH="${pkgs.mkcert}/bin:${pkgs.nssTools}/bin:$PATH"

      mkdir -p "$CAROOT"

      if ! TRUST_STORES=nss mkcert -install; then
        echo "warning: mkcert NSS trust setup failed; run 'TRUST_STORES=nss mkcert -install' manually"
      fi
    '';
  };
}
