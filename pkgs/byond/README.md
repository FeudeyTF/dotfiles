# byond-flake

A Nix flake that packages the **BYOND v516.1680 Windows client** to run under
Wine on Linux. It's a Nix port of the Lutris installer recipe
[39122](https://lutris.net/games/install/39122/view).

BYOND's full client (the pager / DreamSeeker) is Windows-only, so — like Lutris —
this runs it through Wine. (BYOND's *native* Linux build only ships the
server-side tools: DreamDaemon, DreamMaker, etc.)

## Usage

```sh
# Run directly
nix run github:you/byond-flake     # or: nix run .   from a checkout

# Or build and put it on PATH
nix build .#byond
./result/bin/byond
```

The **first launch** performs a one-time, network-heavy setup in a Wine prefix
(it downloads winetricks verbs and the WebView2 runtime, and needs a graphical
display). Subsequent launches go straight to BYOND.

## Desktop integration & `byond://` links

The package ships a desktop entry (`share/applications/byond.desktop`) and the
BYOND icon (extracted from the installer's PE resources into the hicolor theme),
and registers itself as the handler for the **`byond://`** URL scheme
(`x-scheme-handler/byond`) — so clicking a "Play Now" hub link or any
`byond://host:port` link launches the client and joins the game. Just install the
package into a profile that XDG scans (e.g. `environment.systemPackages`,
`home.packages`, or `nix profile install`); the entry + MIME handler register
automatically.

BYOND's pager is **single-instance** — a second `byond.exe` normally hands its URL
to the already-running pager via wineserver IPC, which only works inside one jail.
The launcher preserves this: exactly one jail owns the session (guarded by an
`flock`), and other invocations forward their `byond://` URL into it through a
control FIFO. So clicking a link while BYOND is open joins in the existing pager
rather than spawning a second, isolated instance.

## Sandboxing

BYOND is treated as hostile ("treat this program like malware"). Both the one-time
setup and every launch run inside a [bubblewrap](https://github.com/containers/bubblewrap)
jail with a minimal mount set:

| Mount                                   | Mode | Why                                  |
| --------------------------------------- | ---- | ------------------------------------ |
| `/nix/store`                            | ro   | Wine + dependencies                  |
| `/etc` (+ resolved `resolv.conf`)       | ro   | DNS, TLS certs, fonts                |
| `/run/opengl-driver`, `-32`             | ro   | NixOS GPU userspace (dxvk, 32-bit)   |
| `/sys`, `/dev/dri`                      | ro   | GPU enumeration / access             |
| `$BYOND_ROOT`                           | rw   | **the only writable host path**      |
| `/tmp`, `/dev/shm`                      | priv | fresh tmpfs per run                  |

Your real `$HOME` — including `~/Documents` — is **never mounted**. Wine
normally forwards `%USERPROFILE%\Documents` (where BYOND writes `Documents/BYOND`)
to the real `~/Documents`; the launcher neutralizes that symlink and binds
`$BYOND_DOCUMENTS` (under `$BYOND_ROOT`) in its place.

The jail runs in a private PID namespace with `--die-with-parent`, so nothing
outlives the session: when `byond.exe` exits, the kernel reaps the whole
namespace — including any lingering `wineserver`/WebView2 processes (no zombies).
The host network namespace is shared (BYOND needs to reach its hub/servers).

**The entire setup runs in a single, persistent jail.** This matters:
`wineboot --init` registers COM DLLs (e.g. MSXML) asynchronously in helper
processes, and the `--die-with-parent` + PID namespace would kill those helpers
the instant each step's jail exited — leaving a half-initialized prefix. With
MSXML unregistered, the VC++ redist bootstrapper aborts with `CO_E_CLASSSTRING`
(exit 243). One jail (one `wineserver`, with `wineserver -w` after `wineboot`)
lets that async init finish, so the whole setup succeeds inside the sandbox.

Set `BYOND_NO_SANDBOX=1` to bypass the jail (debugging only).

### Unique BYOND HWID

BYOND derives its HWID from the home drive's volume serial number. A bare Wine
prefix has no serial set, so Wine returns one derived from the drive letter
(`C` → `4300-0000`) — **identical on every Wine BYOND install**, which makes
per-HWID identification/bans useless for server hosts. Setup writes a random
`drive_c/.windows-serial` once, giving each install a unique, stable HWID
(`--reset` rerolls it; `--setup` preserves it).

### What the first run does (mirrors the Lutris recipe)

1. Creates a `win64` Wine prefix (wow64 — 32-bit BYOND + 64-bit WebView2).
2. Installs winetricks verbs: `vcrun2022 dxtrans corefonts dxvk`.
3. Sets `msedgewebview2.exe` to Win7 compat mode.
4. Installs the Microsoft Edge WebView2 runtime.
5. Installs BYOND silently (its NSIS installer reports success as exit `50944`).
6. Runs BYOND's bundled DirectX setup if present.

## Launcher commands

```sh
byond             # launch BYOND fresh (kills any running jail first; see below)
byond byond://…   # join a game; forwards into the running pager if one is up
byond --kill      # SIGTERM the running jail (tears down BYOND + its zombie procs)
byond --setup     # force re-run the first-run setup
byond --prefix    # print the Wine prefix path
byond --reset     # delete the Wine prefix
```

A plain `byond` invocation **kills any running jail and starts over** — BYOND leaks
processes heavily, so a clean slate is the sane default for a re-launch (and
`--kill` exposes that explicitly). A `byond://` URL is the exception: it forwards
into the running session (single-instance) rather than restarting it.

## Configuration

| Env var            | Default                                | Purpose                          |
| ------------------ | -------------------------------------- | -------------------------------- |
| `BYOND_ROOT`       | `$XDG_DATA_HOME/byond-flake`           | State root (the only rw mount)   |
| `BYOND_PREFIX`     | `$BYOND_ROOT/prefix`                   | Wine prefix                      |
| `BYOND_DOCUMENTS`  | `$BYOND_ROOT/documents`                | Documents override (`Documents/BYOND`) |
| `BYOND_NO_SANDBOX` | _(unset)_                              | Set to `1` to bypass bubblewrap  |
| `WINEDEBUG`        | `fixme-all`                            | Wine log verbosity               |

All mutable state lives under `$BYOND_ROOT`, **outside** the Nix store.

## Maintenance

- **Wine**: pinned to `wineWow64Packages.staging` (currently 11.14; Lutris requires ≥10.5).
  nixpkgs deprecated the classic-multilib `wineWowPackages` namespace in favor of
  `wineWow64Packages`, which uses Wine's builtin WoW64 mode (a 64-bit unix side
  running 32-bit PE binaries) — verified to run BYOND's 32-bit `byond.exe`. Any
  wine can be pinned back via the `winePackage` override in `flake.nix`.
- **WebView2 installer**: fetched from a Microsoft `fwlink` evergreen redirect, so
  its hash can drift. Refresh with:

  ```sh
  nix store prefetch-file --name MicrosoftEdgeWebView2RuntimeInstallerX64.exe \
    "https://go.microsoft.com/fwlink/?linkid=2124701"
  ```

  then update the hash in [`package/byond.nix`](package/byond.nix).
- **BYOND version**: bump the URL + `version` in `package/byond.nix` and re-prefetch.

