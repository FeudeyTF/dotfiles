{ pkgs, ... }: {
  programs.gh = {
    enable = true;

    gitCredentialHelper = {
      enable = true;
    };

    settings = {
      editor = "nvim";
      git_protocol = "ssh";
      prompt = "enabled";

    };

    extensions = with pkgs; [
      gh-dash
    ];
  };
}
