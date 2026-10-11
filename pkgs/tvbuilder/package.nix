{
  pkgs ? import <nixpkgs> { },
}:

let
  wine = pkgs.wineWow64Packages.stable;

  desktopItem = pkgs.makeDesktopItem {
    name = "tvbuilder";
    exec = "tvbuilder";
    icon = "applications-other";
    desktopName = "TVBuilder";
    categories = [
      "Education"
      "Development"
    ];
  };
in
pkgs.stdenv.mkDerivation {
  pname = "tvbuilder";
  version = "1.0";

  src = ./tvbuilder;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/tvbuilder

    cp -r $src/* $out/share/tvbuilder/

    cat <<EOF > $out/bin/tvbuilder
    #!/bin/sh
    export WINEPREFIX="\$HOME/.local/share/tvbuilder/wine"
    export WINEARCH="win64"

    mkdir -p "\$WINEPREFIX"

    if [ ! -d "\$WINEPREFIX/drive_c" ]; then
      ${wine}/bin/wineboot -i
    fi

    cd $out/share/tvbuilder
    exec ${wine}/bin/wine "$out/share/tvbuilder/tvbuilder-m.exe" "\$@"
    EOF

    chmod +x $out/bin/tvbuilder

    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications/
  '';

  meta = {
    description = "TVBuilder emulation and training software";
    platforms = pkgs.lib.platforms.linux;
  };
}
