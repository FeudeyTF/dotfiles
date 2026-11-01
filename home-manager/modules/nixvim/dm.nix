{ pkgs, ... }:
let
  dm-langserver = pkgs.stdenv.mkDerivation rec {
    pname = "dm-langserver";
    version = "suite-1.12";

    src = pkgs.fetchurl {
      url = "https://github.com/SpaceManiac/SpacemanDMM/releases/download/${version}/dm-langserver";
      sha256 = "sha256-adx5L9MlzwC7S3TBC8v+YLcfwgF+rK8nQy44Blbgrto=";
    };

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/dm-langserver
      chmod +x $out/bin/dm-langserver
    '';
  };
in
{
  # DreamMaker LSP
  autoCmd = [
    {
      event = [ "FileType" ];
      pattern = [ "dm" ];
      command = "lua vim.lsp.start({ name = 'dm-langserver', cmd = { '${dm-langserver}/bin/dm-langserver' }, root_dir = vim.fs.root(0, { 'SpacemanDMM.toml', '.git' }), settings = {}})";
    }
  ];

  filetype = {
    extension = {
      dm = "dm";
      dme = "dm";
    };
  };
}
