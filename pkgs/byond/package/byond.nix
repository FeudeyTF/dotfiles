{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  icoutils, # wrestool/icotool: extract the BYOND icon from the installer PE
  wineWow64Packages,
  winePackage ? wineWow64Packages.stable, # overridable; see flake.nix
  winetricks,
  bubblewrap,
  cabextract,
  p7zip,
  samba, # provides ntlm_auth, occasionally wanted by wine
  gnused,
  coreutils,
  findutils,
  util-linux,
  procps, # pkill, used to terminate MicrosoftEdgeUpdate.exe
  bash,
}:

let
  version = "516.1688";
  # Must run 32-bit PE binaries on x86_64 (BYOND is a 32-bit Windows app):
  # either classic multilib or Wine's builtin WoW64 mode qualifies.
  # wineWow64Packages is the latter (--enable-archs=x86_64,i386). flake.nix pins
  # wineWow64Packages.staging (latest dev + staging patchset); the .stable
  # default here is just a sensible fallback. `winePackage` is overridable so
  # any wine can be pinned back in one line.
  wine = winePackage;

  # Fixed-output sources. Hashes obtained via `nix store prefetch-file`.
  byondInstaller = fetchurl {
    # Lutris pulls this over plain http; we use https + a pinned hash.
    url = "http://www.byond.com/download/build/516/${version}_byond.exe";
    hash = "sha256-0cjZFtaE1RY/iLbOtjEtHLohKOpk0LlMHU5ts16kbiE=";
  };

  # The WebView2 evergreen bootstrapper. NOTE: this fwlink redirects to
  # whatever Microsoft currently ships, so the hash can drift over time.
  # Refresh with:
  #   nix store prefetch-file --name MicrosoftEdgeWebView2RuntimeInstallerX64.exe \
  #     "https://go.microsoft.com/fwlink/?linkid=2124701"
  webview2Installer = fetchurl {
    name = "MicrosoftEdgeWebView2RuntimeInstallerX86.exe";
    url = "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/f9392307-9373-4315-9425-2d1577ac9f02/MicrosoftEdgeWebView2RuntimeInstallerX86.exe";
    hash = "sha256-+G0WeriU3Dt1gtkaxXo1AXjK4K9YkiCiNlGPJnlp3nE=";
  };

  runtimePath = lib.makeBinPath [
    wine
    winetricks
    bubblewrap
    cabextract
    p7zip
    samba
    gnused
    coreutils
    findutils # winetricks and the setup script use `find`
    util-linux # flock: single-instance guard for byond:// URL forwarding
    procps
    bash # runs the setup script / session supervisor inside the jail
  ];
in
stdenvNoCC.mkDerivation {
  pname = "byond";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    icoutils
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec $out/share/byond

    # Stash the Windows installers in the store; the launcher copies them
    # into the prefix workdir on first run.
    install -Dm644 ${byondInstaller}    $out/share/byond/byond-installer.exe
    install -Dm644 ${webview2Installer} $out/share/byond/webview2-installer.exe

    install -Dm755 ${./launcher.sh} $out/libexec/byond-launcher

    makeWrapper $out/libexec/byond-launcher $out/bin/byond \
      --prefix PATH : "${runtimePath}" \
      --set WINE          "${wine}/bin/wine" \
      --set WINESERVER    "${wine}/bin/wineserver" \
      --set BYOND_VERSION "${version}" \
      --set BYOND_INSTALLER    "$out/share/byond/byond-installer.exe" \
      --set BYOND_WEBVIEW2      "$out/share/byond/webview2-installer.exe"

    # Icon: extract the BYOND logo (group icon) from the installer PE and install
    # it into the hicolor theme as "byond" (max available resolution is 48x48).
    wrestool -x --type=14 ${byondInstaller} -o byond.ico
    icotool -x byond.ico
    for sz in 16 32 48; do
      png=$(ls byond_*_"$sz"x"$sz"x32.png 2>/dev/null | head -n1)
      [ -n "$png" ] && install -Dm644 "$png" "$out/share/icons/hicolor/$sz"x"$sz"/apps/byond.png
    done

    # Desktop entry + byond:// URL scheme handler. BYOND registers the protocol
    # in-prefix as `byond.exe "%1"`; our wrapper passes args straight through, so
    # %u (the byond:// URL) reaches byond.exe unchanged.
    install -d $out/share/applications
    cat > $out/share/applications/byond.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=BYOND
    GenericName=Build Your Own Net Dream
    Comment=BYOND game client (Dream Seeker) running under Wine
    Exec=$out/bin/byond %u
    TryExec=$out/bin/byond
    Icon=byond
    Terminal=false
    Categories=Game;
    MimeType=x-scheme-handler/byond;
    StartupNotify=true
    StartupWMClass=byond.exe
    EOF

    runHook postInstall
  '';

  meta = {
    description = "BYOND ${version} Windows client wrapped to run under Wine (Lutris recipe 39122)";
    homepage = "https://www.byond.com/";
    license = lib.licenses.unfree; # BYOND EULA; bundles Microsoft WebView2
    platforms = [ "x86_64-linux" ];
    mainProgram = "byond";
  };
}
