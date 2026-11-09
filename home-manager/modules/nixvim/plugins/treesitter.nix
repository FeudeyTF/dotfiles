{ pkgs, lib, ... }:
let
  localSource = builtins.getEnv "TREE_SITTER_DM_SRC";

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

  localConfig = lib.optionalString (localSource != "") ''
    local source = ${builtins.toJSON localSource}
    local runtime_root = vim.fn.stdpath("data") .. "/site"
    local parser_dir = runtime_root .. "/parser"
    local query_dir = runtime_root .. "/after/queries/dm"
    local parser = parser_dir .. "/dm.so"

    if vim.fn.isdirectory(source) ~= 1 then
      vim.notify(
        "TREE_SITTER_DM_SRC does not exist: " .. source,
        vim.log.levels.ERROR
      )
    else
      vim.fn.mkdir(parser_dir, "p")
      vim.fn.mkdir(query_dir, "p")

      local command = {
        "${pkgs.stdenv.cc}/bin/cc",
        "-O2",
        "-fPIC",
        "-shared",
        "-I" .. source .. "/src",
        source .. "/src/parser.c",
      }

      if vim.fn.filereadable(source .. "/src/scanner.c") == 1 then
        table.insert(command, source .. "/src/scanner.c")
      end

      table.insert(command, "-o")
      table.insert(command, parser)

      local result = vim.system(command, { text = true }):wait()

      if result.code ~= 0 then
        vim.notify(
          "Failed to compile DreamMaker parser:\n" .. result.stderr,
          vim.log.levels.ERROR
        )
      else
        local query_source = source .. "/queries/neovim"
        local query_files = vim.fn.glob(query_source .. "/*.scm", false, true)

        for _, file in ipairs(query_files) do
          local name = vim.fn.fnamemodify(file, ":t")
          vim.fn.writefile(
            vim.fn.readfile(file),
            query_dir .. "/" .. name
          )
        end

        vim.opt.runtimepath:prepend(runtime_root)

        if vim.treesitter.query.invalidate then
          vim.treesitter.query.invalidate()
        end
      end
    end
  '';
in
{
  plugins.treesitter = {
    enable = true;
    nixGrammars = true;

    grammarPackages = [
      pkgs.tree-sitter-grammars.tree-sitter-lua
      pkgs.tree-sitter-grammars.tree-sitter-regex
    ]
    ++ lib.optional (localConfig == "") tree-sitter-dm;

    settings.highlight.enable = true;
  };

  extraConfigLua = localConfig;
}
