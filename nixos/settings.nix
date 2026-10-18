{
  nix = {
    settings = {
      warn-dirty = false;
      show-trace = false;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    channel.enable = false;
  };

  console.keyMap = "dvorak-programmer";

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';
}
