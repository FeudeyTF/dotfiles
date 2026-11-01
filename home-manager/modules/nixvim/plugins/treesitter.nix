{ pkgs, ... }:
let
  tree-sitter-dm = pkgs.tree-sitter.buildGrammar {
    language = "dm";
    version = "0.26.rev1";

    src = pkgs.fetchFromGitHub {
      owner = "FeudeyTF";
      repo = "tree-sitter-dm";
      rev = "270b6d8b6c938b61b301ac78205dd8724f3ffea6";
      hash = "sha256-I7Boj+lht5ZnfOCBZ2NARpFmnl1pKLpSCT/I7YHr3+s=";
    };
  };
in
{
  plugins.treesitter = {
    enable = true;

    nixGrammars = true;

    grammarPackages = [
      tree-sitter-dm
      pkgs.tree-sitter-grammars.tree-sitter-lua
      pkgs.tree-sitter-grammars.tree-sitter-regex
    ];

    settings = {
      highlight = {
        enable = true;
      };
    };
  };
}
