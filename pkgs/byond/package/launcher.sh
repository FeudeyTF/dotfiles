#!/usr/bin/env bash
# Created by sriptis - https://github.com/scriptis
#
# BYOND-under-Wine launcher, sandboxed with bubblewrap.
#
# Mirrors the Lutris installer (lutris.net/games/install/39122):
#   create prefix -> winetricks (vcrun2022 dxtrans corefonts dxvk)
#   -> install WebView2 -> install BYOND -> run bundled DirectX setup.
#
# BYOND is treated as hostile: every wine invocation (setup AND launch) runs
# inside a bubblewrap jail with a minimal mount set:
#   - ro:  /nix/store, /etc, NixOS GPU userspace (/run/opengl-driver{,-32})
#   - rw:  $BYOND_ROOT only (Wine prefix + Documents override + sandbox $HOME)
#   - the real $HOME (and the user's ~/Documents) are never mounted.
# A private PID namespace + --die-with-parent means nothing survives quit:
# when byond.exe exits, the kernel reaps the whole namespace (no zombie
# wineserver/webview processes).
#
# Mutable state lives under $BYOND_ROOT (NOT the Nix store). First run does the
# setup; subsequent runs go straight to byond.exe.
set -euo pipefail

# --- configuration -----------------------------------------------------------
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${BYOND_ROOT:=$XDG_DATA_HOME/byond-flake}"
: "${BYOND_PREFIX:=$BYOND_ROOT/prefix}"
: "${BYOND_DOCUMENTS:=$BYOND_ROOT/documents}"   # rw Documents override
SANDBOX_HOME="$BYOND_ROOT/home"                 # fake $HOME inside the jail

export WINEPREFIX="$BYOND_PREFIX"
export WINEARCH="win64"        # wow64: 32-bit BYOND + 64-bit WebView2
export WINEDEBUG="${WINEDEBUG:-fixme-all}"
# Don't let wine pop up its mono/gecko installer dialogs during setup.
export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:-mscoree=d;mshtml=d}"

BYOND_BIN="$WINEPREFIX/drive_c/Program Files (x86)/BYOND/bin"
SETUP_MARKER="$WINEPREFIX/.byond-flake-setup-complete"

log() { printf '\033[1;36m[byond-flake]\033[0m %s\n' "$*" >&2; }

# Where Wine forwards %USERPROFILE%\Documents. BYOND writes Documents/BYOND here.
wine_docs_dir() {
  printf '%s\n' "$WINEPREFIX/drive_c/users/${USER:-$(id -un)}/Documents"
}

# --- sandbox -----------------------------------------------------------------
# Build the bwrap argv into the global array `bw`. Rebuilt per-invocation so the
# Documents bind is only added once its mountpoint exists.
build_sandbox() {
  mkdir -p "$BYOND_ROOT" "$SANDBOX_HOME" "$BYOND_DOCUMENTS"

  bw=(
    bwrap
    # read-only system
    --ro-bind /nix/store /nix/store
    --ro-bind-try /etc /etc
    --ro-bind-try /run/opengl-driver /run/opengl-driver        # NixOS GPU (64-bit)
    --ro-bind-try /run/opengl-driver-32 /run/opengl-driver-32  # NixOS GPU (32-bit, for BYOND)
    --ro-bind-try /sys /sys
    --proc /proc
    # the only writable host path
    --bind "$BYOND_ROOT" "$BYOND_ROOT"
    --setenv HOME "$SANDBOX_HOME"
    # isolation + lifecycle
    --unshare-pid
    --unshare-ipc
    --unshare-uts
    --unshare-cgroup-try
    --new-session
    --die-with-parent
    # synthetic /dev (+ GPU), private /tmp and /dev/shm
    --dev /dev
    --dev-bind-try /dev/dri /dev/dri                           # GPU access for dxvk
    --tmpfs /tmp
    --ro-bind-try /tmp/.X11-unix /tmp/.X11-unix
    --tmpfs /dev/shm                                           # private POSIX shm (wine/dxvk)
  )

  # DNS: on NixOS /etc/resolv.conf is a symlink into /run (systemd-resolved),
  # which isn't mounted here. Bind the resolved file over it so hostname lookups
  # (BYOND hub, winetricks downloads) work. Loopback resolver stays reachable
  # because we share the host net namespace.
  # Bind it at its own resolved path (e.g. /run/systemd/resolve/stub-resolv.conf)
  # so the /etc/resolv.conf symlink chain resolves to it; binding directly onto
  # /etc/resolv.conf fails because bwrap follows the dangling symlink first.
  local resolv; resolv="$(readlink -f /etc/resolv.conf 2>/dev/null || true)"
  [ -n "$resolv" ] && [ -e "$resolv" ] && bw+=( --ro-bind "$resolv" "$resolv" )

  # Runtime dir: wineserver puts its socket under $XDG_RUNTIME_DIR/wine and wants a
  # user-owned 0700, tmpfs-backed dir (a bare bwrap --tmpfs is root-owned 0755, which
  # wine complains about). Mount a dedicated tmpfs SUBDIR of the real runtime dir
  # (user-owned, 0700) *at* $XDG_RUNTIME_DIR and bind only the display/audio sockets
  # on top, so the host's other session sockets (dbus, ssh-agent, ...) stay hidden.
  if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
    local sbrun="$XDG_RUNTIME_DIR/byond-flake"
    mkdir -p "$sbrun"; chmod 700 "$sbrun"
    bw+=( --bind "$sbrun" "$XDG_RUNTIME_DIR" )
    [ -n "${XAUTHORITY:-}" ] && bw+=( --ro-bind-try "$XAUTHORITY" "$XAUTHORITY" )
    case "${WAYLAND_DISPLAY:-}" in
      "") ;;
      /*) bw+=( --ro-bind-try "$WAYLAND_DISPLAY" "$WAYLAND_DISPLAY" ) ;;
      *)  bw+=( --ro-bind-try "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ) ;;
    esac
    bw+=( --ro-bind-try "$XDG_RUNTIME_DIR/pulse/native" "$XDG_RUNTIME_DIR/pulse/native" )
    bw+=( --ro-bind-try "$XDG_RUNTIME_DIR/pipewire-0"   "$XDG_RUNTIME_DIR/pipewire-0" )
  else
    [ -n "${XAUTHORITY:-}" ] && bw+=( --ro-bind-try "$XAUTHORITY" "$XAUTHORITY" )
  fi

  # rw Documents override, shadowing Wine's in-prefix Documents dir. Added last
  # so it mounts on top of the $BYOND_ROOT bind. Only if the mountpoint exists.
  local docs; docs="$(wine_docs_dir)"
  if [ -e "$docs" ] && [ ! -L "$docs" ]; then
    bw+=( --bind "$BYOND_DOCUMENTS" "$docs" )
  fi
}

# Replace Wine's auto-created Documents symlink (which points at the real
# ~/Documents) with a plain dir, so it's a clean bind mountpoint and never
# forwards to the user's home.
neutralize_documents_symlink() {
  local docs; docs="$(wine_docs_dir)"
  mkdir -p "$BYOND_DOCUMENTS"
  if [ -L "$docs" ]; then
    log "Redirecting Wine Documents away from your real ~/Documents"
    rm -f "$docs"
  fi
  mkdir -p "$docs"
}

# --- first-run setup ---------------------------------------------------------
# The ENTIRE setup runs inside ONE persistent jail. This is essential: each
# `wineboot --init` kicks off asynchronous prefix initialization (registering
# COM DLLs like MSXML in helper processes). If we ran each step in its own jail,
# bwrap's --die-with-parent + PID namespace would kill those helpers the moment
# wineboot returned, leaving a half-initialized prefix (no MSXML registration) --
# which makes the vc_redist bootstrapper abort with CO_E_CLASSSTRING (exit 243).
# Keeping one wineserver alive across all steps lets `wineserver -w` actually
# wait for that async init to finish.
setup() {
  log "Setting up Wine prefix at $WINEPREFIX (one-time, network-heavy step)"
  mkdir -p "$WINEPREFIX"

  # Randomize the C: volume serial ONCE. BYOND derives its HWID from the home
  # drive's serial; a bare Wine prefix has no .windows-serial file, so Wine reports
  # serial 0 and every Wine BYOND install collides on one HWID. Wine reads this file
  # as a hex string (get_filesystem_serial); write a random non-zero 32-bit value.
  # Guarded by existence so the HWID is stable across re-setup (only `--reset` rerolls).
  local serialfile="$WINEPREFIX/drive_c/.windows-serial"
  if [ ! -f "$serialfile" ]; then
    mkdir -p "$WINEPREFIX/drive_c"
    local serial; serial="$(od -An -N4 -tx1 /dev/urandom | tr -d ' \n')"
    [ "$serial" = "00000000" ] && serial="b10cca11"   # never the colliding default
    printf '%s\n' "$serial" > "$serialfile"
    log "Assigned this install a unique C: serial (BYOND HWID): ${serial:0:4}-${serial:4:4}"
  fi

  local payload="$BYOND_ROOT/.byond-setup.sh"
  cat >"$payload" <<'SETUP'
#!/usr/bin/env bash
set -uo pipefail
log() { printf '\033[1;36m[byond-flake]\033[0m %s\n' "$*" >&2; }

log "Initializing Wine prefix"
"$WINE" wineboot --init
"$WINESERVER" -w   # wait for async DLL/COM registration (MSXML etc.) to finish

log "Installing Windows runtime bits via winetricks (vcrun2022 dxtrans corefonts dxvk)"
# fontsmooth=rgb isn't in the Lutris recipe, but without it Wine renders text with
# no antialiasing (the "scuffed" look). corefonts gives the real font metrics
# (fixing kerning); both need `find` on PATH, which is why findutils is a dep.
winetricks -q --force vcrun2022 dxtrans corefonts fontsmooth=rgb dxvk
"$WINESERVER" -w

log "Setting WebView2 to Win7 compatibility mode"
"$WINE" reg add 'HKEY_CURRENT_USER\Software\Wine\AppDefaults\msedgewebview2.exe' \
  /v Version /d win7 /f
"$WINESERVER" -w

log "Installing Microsoft Edge WebView2 runtime"
"$WINE" "$BYOND_WEBVIEW2" /install || true
pkill -f -i 'MicrosoftEdgeUpdate.exe' 2>/dev/null || true
"$WINESERVER" -w

log "Installing BYOND $BYOND_VERSION (silent)"
# BYOND's NSIS installer doesn't exit 0 on success (observed 50944 and 199 across
# versions). The authoritative success check is byond.exe existing afterwards, so
# this is informational only.
rc=0; "$WINE" "$BYOND_INSTALLER" /S || rc=$?
case "$rc" in 0|199|50944) ;; *) log "Note: BYOND installer exited with $rc" ;; esac
"$WINESERVER" -w

# BYOND bundles a DirectX redistributable; run it silently if present.
dxsetup="$(find "$WINEPREFIX/drive_c/Program Files (x86)/BYOND" \
  -iname 'dxsetup.exe' -print -quit 2>/dev/null || true)"
if [ -n "$dxsetup" ]; then
  log "Running BYOND's bundled DirectX setup"
  "$WINE" "$dxsetup" /silent || true
  "$WINESERVER" -w
fi
SETUP

  if [ -n "${BYOND_NO_SANDBOX:-}" ]; then
    bash "$payload"
  else
    build_sandbox
    "${bw[@]}" -- bash "$payload"
  fi
  rm -f "$payload"

  neutralize_documents_symlink

  if [ ! -f "$BYOND_BIN/byond.exe" ]; then
    log "ERROR: BYOND install did not produce byond.exe under:"
    log "  $BYOND_BIN"
    log "Inspect the prefix or remove it ($WINEPREFIX) and retry."
    exit 1
  fi

  touch "$SETUP_MARKER"
  log "Setup complete."
}

# Per-prefix runtime state for the single-instance machinery.
LOCK="$BYOND_ROOT/instance.lock"
FIFO="$BYOND_ROOT/control.fifo"
PIDFILE="$BYOND_ROOT/jail.pid"

# SIGTERM the running jail for this prefix (if any) and wait for it to die. Killing
# bwrap destroys its PID namespace, so every wine/byond process inside dies with it
# -- including the hundreds of zombies BYOND likes to leave around. SIGKILL is a
# fallback if it doesn't go down on TERM.
kill_jail() {
  [ -f "$PIDFILE" ] || return 0
  local pid; pid="$(cat "$PIDFILE" 2>/dev/null || true)"
  rm -f "$PIDFILE"
  [ -n "$pid" ] || return 0
  # guard against a recycled PID: it must still be our jail (cmdline names our root)
  kill -0 "$pid" 2>/dev/null || return 0
  tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | grep -q -- "$BYOND_ROOT" || return 0
  log "Stopping running BYOND jail (pid $pid)"
  kill -TERM "$pid" 2>/dev/null || true
  for _ in $(seq 1 50); do kill -0 "$pid" 2>/dev/null || return 0; sleep 0.1; done
  kill -KILL "$pid" 2>/dev/null || true
}

# Own the session (this process holds the flock for its lifetime) and run the
# pager in ONE persistent jail, replaying forwarded byond:// URLs into it.
run_session() {
  rm -f "$FIFO"; mkfifo "$FIFO"
  export BYOND_BIN BYOND_CONTROL_FIFO="$FIFO" BYOND_INITIAL_URL="$url"
  local session="$BYOND_ROOT/.byond-session.sh"
  cat >"$session" <<'SESSION'
#!/usr/bin/env bash
set -u
# Launch the pager (joining BYOND_INITIAL_URL if we were opened with one).
if [ -n "${BYOND_INITIAL_URL:-}" ]; then
  "$WINE" "$BYOND_BIN/byond.exe" "$BYOND_INITIAL_URL" &
else
  "$WINE" "$BYOND_BIN/byond.exe" &
fi
pager=$!
# Replay forwarded byond:// URLs into the SAME wineserver until the pager quits;
# byond.exe's own single-instance logic then hands each URL to the pager.
( while read -r u < "$BYOND_CONTROL_FIFO"; do
    [ -n "$u" ] && "$WINE" "$BYOND_BIN/byond.exe" "$u" >/dev/null 2>&1 &
  done ) &
reader=$!
wait "$pager"
kill "$reader" 2>/dev/null
SESSION

  log "Launching BYOND"
  if [ -n "${BYOND_NO_SANDBOX:-}" ]; then
    bash "$session" & local jail=$!
  else
    build_sandbox
    "${bw[@]}" -- bash "$session" & local jail=$!
  fi
  printf '%s\n' "$jail" > "$PIDFILE"   # so a later kill_jail / --kill can find us
  wait "$jail"
  rm -f "$PIDFILE"
}

# --- main --------------------------------------------------------------------
case "${1:-}" in
  --setup)   shift; rm -f "$SETUP_MARKER"; setup; exit 0 ;;
  --prefix)  printf '%s\n' "$WINEPREFIX"; exit 0 ;;
  --reset)   log "Removing prefix $WINEPREFIX"; rm -rf "$WINEPREFIX"; exit 0 ;;
  --kill)    kill_jail; exit 0 ;;
esac

# A byond:// URL as the first argument means "open this in BYOND" (this is how the
# desktop entry's x-scheme-handler/byond invokes us).
url=""
case "${1:-}" in byond://*) url="$1" ;; esac

[ -f "$SETUP_MARKER" ] || setup

# Idempotent: keep Documents pointed at the override even after wine upgrades.
neutralize_documents_symlink

# BYOND's pager is single-instance: a second byond.exe hands its URL to the running
# pager via in-process (wineserver) IPC, which only works WITHIN one jail. So one
# jail owns the session (flock); a URL handler invocation forwards its URL into it
# through a control FIFO. A plain CLI invocation, however, means "give me a fresh
# BYOND" -- so it kills the running jail first and starts over (BYOND leaks badly,
# and a clean slate is the saner default).
exec 9>"$LOCK"
if [ -n "$url" ]; then
  if ! flock -n 9; then
    log "Forwarding $url to the running BYOND instance"
    timeout 10 bash -c 'printf "%s\n" "$0" > "$1"' "$url" "$FIFO" \
      || log "Could not reach the running instance (it may be starting or stopping)."
    exit 0
  fi
  # got the lock -> nothing running -> become the owner and join the URL ourselves
else
  kill_jail                       # plain launch: tear down any existing jail first
  flock -w 15 9 || { log "Another BYOND instance won't release; try 'byond --kill'."; exit 1; }
fi

run_session
