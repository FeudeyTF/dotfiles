{
  programs.bash = {
    enable = true;

    shellAliases = {
      rebuild = "nh os switch -H Feudey";
      clean = "nh clean all --no-direnv --no-gcroots";
    };
  };
}
