{
  lib,
  writeText,
  stdenvNoCC,
  fetchFromGitHub,
  extraListExclude ? [ ],
  extraListGeneral ? [ ],
  extraIpsetAll ? [ ],
  extraIpsetExclude ? [ ],
  extraListGoogle ? [ ],
}:
let
  f = list: writeText "list.txt" ("\n" + (lib.strings.concatLines list));
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zapret-discord-youtube";
  version = "1.10.3";
  hash = "sha256-7CI4CO85Ggg0w94t3+dreWNYdIJRMTZ72PRRMmHCudk=";

  src = fetchFromGitHub {
    owner = "Flowseal";
    repo = "zapret-discord-youtube";
    rev = finalAttrs.version;
    hash = finalAttrs.hash;
  };

  buildPhase = ''
    mkdir lists-with-extra
    cat lists/list-general.txt ${f extraListGeneral} > lists-with-extra/list-general.txt
    cat lists/ipset-all.txt ${f extraIpsetAll} > lists-with-extra/ipset-all.txt
    cat lists/list-exclude.txt ${f extraListExclude} > lists-with-extra/list-exclude.txt
    cat lists/ipset-exclude.txt ${f extraIpsetExclude} > lists-with-extra/ipset-exclude.txt
    cat lists/list-google.txt ${f extraListGoogle} > lists-with-extra/list-google.txt
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r bin/*.bin $out/bin

    mkdir -p $out/lists
    cp -r lists-with-extra/*.txt $out/lists
  '';

  passthru = {
    src = finalAttrs.src;
  };

  meta = {
    description = "Toolkit for bypassing DPI restrictions and restoring access to Discord and YouTube";
    homepage = "https://github.com/Flowseal/zapret-discord-youtube";
    license = lib.licenses.mit;
    mainProgram = "general.bat";
    platforms = lib.platforms.linux;
  };
})
