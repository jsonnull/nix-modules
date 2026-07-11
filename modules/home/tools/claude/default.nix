{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:

let
  cfg = config.tools.claude;
  llm-agents = flakeInputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  claude-notifications-go = pkgs.callPackage ../../../../packages/claude-notifications-go { };
in
{
  options.tools.claude = {
    enable = lib.mkEnableOption "Enable Claude Code";
    notifications.enable = lib.mkEnableOption "Enable Claude Code notifications";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = [ llm-agents.claude-code ];
      }

      (lib.mkIf cfg.notifications.enable {
        home.packages = [ claude-notifications-go ];

        home.file.".claude/claude-notifications-go/config.json".text = builtins.toJSON {
          notifications = {
            desktop = {
              enabled = true;
              sound = true;
              volume = 1.0;
              appIcon = "${claude-notifications-go}/share/claude-notifications/claude_icon.png";
              clickToFocus = true;
              terminalBundleId = "";
            };
            webhook = {
              enabled = false;
              preset = "slack";
              url = "";
              chat_id = "";
              format = "json";
              headers = { };
            };
            suppressQuestionAfterTaskCompleteSeconds = 12;
            suppressQuestionAfterAnyNotificationSeconds = 7;
            suppressForSubagents = true;
            suppressFilters = [ ];
          };
          statuses = {
            task_complete = {
              title = "Completed";
              sound = "${claude-notifications-go}/share/claude-notifications/task-complete.mp3";
              keywords = [
                "completed"
                "done"
                "finished"
              ];
            };
            review_complete = {
              title = "Review";
              sound = "${claude-notifications-go}/share/claude-notifications/review-complete.mp3";
              keywords = [
                "review"
                "analyzed"
                "analysis"
              ];
            };
            question = {
              title = "Question";
              sound = "${claude-notifications-go}/share/claude-notifications/question.mp3";
              keywords = [
                "question"
                "clarify"
              ];
            };
            plan_ready = {
              title = "Plan";
              sound = "${claude-notifications-go}/share/claude-notifications/plan-ready.mp3";
              keywords = [
                "plan"
                "strategy"
              ];
            };
            session_limit_reached = {
              title = "Session Limit Reached";
              sound = "${claude-notifications-go}/share/claude-notifications/question.mp3";
              keywords = [
                "session limit"
                "limit reached"
              ];
            };
            api_error = {
              title = "API Error: 401";
              sound = "${claude-notifications-go}/share/claude-notifications/question.mp3";
              keywords = [
                "api error"
                "401"
                "authentication"
                "login"
              ];
            };
            api_error_overloaded = {
              title = "API Error";
              sound = "${claude-notifications-go}/share/claude-notifications/question.mp3";
              keywords = [
                "api error"
                "overloaded"
                "rate limit"
                "timeout"
                "server error"
                "529"
                "500"
              ];
            };
          };
        };
      })
    ]
  );
}
