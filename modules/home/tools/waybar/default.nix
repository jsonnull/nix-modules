{
  lib,
  pkgs,
  flakeInputs,
  config,
  ...
}:
let
  cfg = config.tools.waybar;
  ccusage = flakeInputs.ccusage.packages.${pkgs.stdenv.hostPlatform.system}.default;
  agentUsage = pkgs.writeShellScript "waybar-agent-usage" ''
    today="$(${pkgs.coreutils}/bin/date +%F)"

    if ! usage="$(${ccusage}/bin/ccusage daily --offline --json 2>/dev/null)"; then
      ${pkgs.coreutils}/bin/printf '{"text":"$--","tooltip":"ccusage unavailable","class":"error"}\n'
      exit 0
    fi

    cost="$(${pkgs.jq}/bin/jq --arg today "$today" -r '
      (.daily // [])
      | map(select(.period == $today))
      | first
      | .totalCost // 0
    ' <<< "$usage")"

    text="$(${pkgs.coreutils}/bin/printf '$%.2f' "$cost")"
    tooltip="$(${pkgs.jq}/bin/jq --arg today "$today" -r '
      def abbreviate:
        if . >= 1000000000 then
          "\(((. / 1000000000) * 100 | round / 100))B"
        elif . >= 1000000 then
          "\(((. / 1000000) * 100 | round / 100))M"
        elif . >= 1000 then
          "\(((. / 1000) * 100 | round / 100))K"
        else
          tostring
        end;

      (.daily // [])
      | map(select(.period == $today))
      | first as $row
      | if $row == null then
          "No agent usage recorded today"
        else
          "Agents: \(($row.metadata.agents // []) | join(", "))\nTokens: \(($row.totalTokens // 0 | abbreviate))\nCost: $\((($row.totalCost // 0) * 100 | round) / 100)"
        end
    ' <<< "$usage")"

    ${pkgs.jq}/bin/jq -cn --arg text "$text" --arg tooltip "$tooltip" '{ text: $text, tooltip: $tooltip }'
  '';
in
{
  options.tools.waybar.enable = lib.mkEnableOption "Enable Waybar";

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;

      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 36;

        modules-left = [
          "niri/workspaces"
        ];
        modules-right = [
          "custom/agent-usage"
          "tray"
          "clock"
        ];

        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "●";
            default = "○";
          };
        };

        clock = {
          format = "{:%a %b %d  %H:%M}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        tray = {
          spacing = 8;
        };

        "custom/agent-usage" = {
          exec = "${agentUsage}";
          interval = 120;
          return-type = "json";
        };
      };

      style = ''
        * {
          font-family: "Inter", "Iosevka Nerd Font";
          font-size: 14px;
          min-height: 0;
        }

        window#waybar {
          background: #000000;
          color: #f2f4f8;
        }

        #workspaces button {
          padding: 0 8px;
          color: #525252;
          border: none;
          border-radius: 0;
        }

        #workspaces button.active {
          color: #33b1ff;
        }

        #clock {
          padding: 0 12px;
          color: #f2f4f8;
          font-weight: 500;
        }

        #custom-agent-usage {
          padding: 0 12px;
          color: #42be65;
          font-weight: 500;
        }

        #custom-agent-usage.error {
          color: #ff8389;
        }

        #tray {
          padding: 0 8px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
        }

        tooltip {
          background: #161616;
          border: 1px solid #525252;
          border-radius: 4px;
        }

        tooltip label {
          color: #f2f4f8;
        }
      '';
    };
  };
}
