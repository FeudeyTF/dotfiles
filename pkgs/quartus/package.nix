{
  pkgsi686Linux,
  buildFHSEnv,
  callPackage,
  makeDesktopItem,
  runtimeShell,
  runCommand,
  quartus-prime-lite,
  supportedDevices ? [
    "MAX 10 FPGA"
  ],
  unwrapped ? callPackage ./quartus.nix { inherit supportedDevices; },
}:

let
  quartusDesktopItem = makeDesktopItem {
    name = "quartus-prime-lite";
    exec = "quartus";
    icon = "quartus";
    desktopName = "Quartus";
    genericName = "Quartus Prime";
    categories = [ "Development" ];
  };

  modelSimDesktopItem = makeDesktopItem {
    name = "modelsim";
    exec = "vsim";
    desktopName = "ModelSim";
    genericName = "Model-Sim";
    categories = [ "Development" ];
  };
  # I think modelsim_ase/linux/vlm checksums itself, so use FHSUserEnv instead of `patchelf`
in
buildFHSEnv rec {
  name = "quartus-prime-lite"; # wrapped

  targetPkgs =
    pkgs: with pkgs; [
      (runCommand "ld-lsb-compat" { } ''
        mkdir -p "$out/lib"
        ln -sr "${glibc}/lib/ld-linux-x86-64.so.2" "$out/lib/ld-lsb-x86-64.so.3"
        ln -sr "${pkgsi686Linux.glibc}/lib/ld-linux.so.2" "$out/lib/ld-lsb.so.3"
      '')
      # quartus requirements
      glib
      libice
      libsm
      zlib
      libudev0-shim
      # qsys requirements
      libxtst
      libxi
    ];

  # Also support 32-bit executables.
  multiArch = true;

  multiPkgs =
    pkgs:
    let
      libpng12 = pkgs.stdenv.mkDerivation rec {
        pname = "libpng";
        version = "1.2.59";

        src = pkgs.fetchurl {
          url = "mirror://sourceforge/libpng/libpng12/${version}/libpng-${version}.tar.xz";
          sha256 = "sha256-tGNfFbitzMitCTTupIXvWcxMriTQ8DAKmpQeUZdP/Mc=";
        };

        propagatedBuildInputs = [ pkgs.zlib ];
      };

      freetype = pkgs.freetype.override { libpng = libpng12; };
      fontconfig = pkgs.fontconfig.override { inherit freetype; };
      libxft = pkgs.libxft.override { inherit freetype fontconfig; };
    in
    with pkgs;
    [
      # modelsim requirements
      libxml2
      ncurses5
      unixodbc
      libxft
      # common requirements
      freetype
      fontconfig
      libpng12
      libx11
      libxext
      libxrender
      libxcrypt-legacy
    ];

  extraInstallCommands = ''
    mkdir -p $out/share/applications $out/share/icons/128x128
    ln -s ${quartusDesktopItem}/share/applications/* $out/share/applications
    ln -s ${modelSimDesktopItem}/share/applications/* $out/share/applications
    ln -s ${unwrapped}/licenses/images/dc_quartus_panel_logo.png $out/share/icons/128x128/quartus.png

    progs_to_wrap=(
      "${unwrapped}"/quartus/bin/*
      "${unwrapped}"/quartus/sopc_builder/bin/qsys-{generate,edit,script}
      "${unwrapped}"/modelsim_ase/bin/*
      "${unwrapped}"/modelsim_ase/linuxaloem/lmutil
    )

    wrapper=$out/bin/${name}
    progs_wrapped=()
    for prog in ''${progs_to_wrap[@]}; do
        relname="''${prog#"${unwrapped}/"}"
        wrapped="$out/$relname"
        progs_wrapped+=("$wrapped")
        mkdir -p "$(dirname "$wrapped")"
        echo "#!${runtimeShell}" >> "$wrapped"
        case "$relname" in
            modelsim_ase/*)
                echo "export NIXPKGS_IS_MODELSIM_WRAPPER=1" >> "$wrapped"
                ;;
        esac
        echo "$wrapper $prog \"\$@\"" >> "$wrapped"
    done

    cd $out
    chmod +x ''${progs_wrapped[@]}
    # link into $out/bin so executables become available on $PATH
    ln --symbolic --relative --target-directory ./bin ''${progs_wrapped[@]}
  '';

  profile = ''
    # LD_PRELOAD fixes issues in the licensing system that cause memory corruption and crashes when
    # starting most operations in many containerized environments, including WSL2, Docker, and LXC
    # (a similiar fix involving LD_PRELOADing tcmalloc did not solve the issue in my situation)
    # https://community.intel.com/t5/Intel-FPGA-Software-Installation/Running-Quartus-Prime-Standard-on-WSL-crashes-in-libudev-so/m-p/1189032
    #
    # But, as can be seen in the above resource, LD_PRELOADing libudev breaks
    # compiling encrypted device libraries in ModelSim (with error
    # `(vlog-2163) Macro `<protected> is undefined.`), so only use LD_PRELOAD
    # for non-ModelSim wrappers.
    if [ "$NIXPKGS_IS_MODELSIM_WRAPPER" != 1 ]; then
        export LD_PRELOAD=''${LD_PRELOAD:+$LD_PRELOAD:}/usr/lib/libudev.so.0
    fi

    if [ "$NIXPKGS_IS_MODELSIM_WRAPPER" = 1 ]; then
       export LD_LIBRARY_PATH="${pkgsi686Linux.ncurses5}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    fi
  '';

  # Run the wrappers directly, instead of going via bash.
  runScript = "";

  passthru = {
    inherit unwrapped;
    tests = {
      modelsimEncryptedModel = runCommand "quartus-prime-lite-test-modelsim-encrypted-model" { } ''
        "${quartus-prime-lite}/bin/vlog" "${quartus-prime-lite.unwrapped}/modelsim_ase/altera/verilog/src/arriav_atoms_ncrypt.v"
        touch "$out"
      '';
    };
  };
}
