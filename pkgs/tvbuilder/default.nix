{
  lib,
  fetchFromGitHub,
  godot_4_4,
  godot_4_4-export-templates-bin,
  libGL,
  libX11,
  libXcursor,
  libXext,
  libXi,
  libXinerama,
  libXrandr,
  libXrender,
  libdecor,
  libxkbcommon,
  makeWrapper,
  makeDesktopItem,
  wayland,
  alsa-lib,
  fontconfig,
  freetype,
  stdenv,
}:

let
  version = "1.4";

  runtimeLibs = [
    alsa-lib
    fontconfig
    freetype
    libGL
    libX11
    libXcursor
    libXext
    libXi
    libXinerama
    libXrandr
    libXrender
    libdecor
    libxkbcommon
    wayland
  ];

  desktopItem = makeDesktopItem {
    name = "tvbuilder";
    exec = "tvbuilder";
    icon = "tvbuilder";
    desktopName = "TVBuilder";
    genericName = "Digital logic circuit simulator";
    categories = [
      "Education"
      "Development"
    ];
  };
in
stdenv.mkDerivation {
  pname = "tvbuilder";
  inherit version;

  src = fetchFromGitHub {
    owner = "hoppa1231";
    repo = "tvbuilder-m";
    rev = "a777e5b639cb3c91707272f62b98b358c15b66a7";
    hash = "sha256-DLsgfZixI0kVgk9s+3CJlGaY/fG8Zoq35P7iXRaLR14=";
  };

  nativeBuildInputs = [
    godot_4_4
    makeWrapper
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    export HOME="$(mktemp -d)"
    mkdir -p "$HOME/.local/share/godot/export_templates"

    ln -s "${godot_4_4-export-templates-bin}/share/godot/export_templates/"* \
      "$HOME/.local/share/godot/export_templates/"

    mkdir -p "$out/bin"
    godot --headless --path . --export-release "Linux" "$out/bin/tvbuilder"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mv "$out/bin/tvbuilder" "$out/libexec-tvbuilder"

    makeWrapper "$out/libexec-tvbuilder" "$out/bin/tvbuilder" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"

    install -Dm644 icon.svg \
      "$out/share/icons/hicolor/scalable/apps/tvbuilder.svg"

    install -Dm644 ${desktopItem}/share/applications/tvbuilder.desktop \
      "$out/share/applications/tvbuilder.desktop"

    runHook postInstall
  '';

  meta = {
    description = "Digital logic circuit simulator based on Soviet and Russian microcircuits";
    homepage = "https://github.com/hoppa1231/tvbuilder-m";
    license = lib.licenses.gpl3Only;
    mainProgram = "tvbuilder";
    platforms = [ "x86_64-linux" ];
  };
}
