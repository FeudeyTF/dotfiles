{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tg-ws-proxy";
  version = "1.11.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Flowseal";
    repo = "tg-ws-proxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ib8Ka5W3l0n4YTLREg/zZNjv2gK4aKYYZRFisTBOEZY=";
  };

  build-system = [ python3Packages.hatchling ];

  dependencies = with python3Packages; [
    certifi
    cryptography
    httpx
    h2
  ];

  pythonRemoveDeps = [
    "pyperclip"
    "psutil"
    "pillow"
    "customtkinter"
    "pystray"
    "pyobjc-framework-cocoa"
  ];

  pythonRelaxDeps = true;

  doCheck = false;
  pythonImportsCheck = [ "proxy" ];

  meta = {
    description = "Local MTProto proxy for Telegram that tunnels traffic over WebSocket";
    homepage = "https://github.com/Flowseal/tg-ws-proxy";
    license = lib.licenses.mit;
    mainProgram = "tg-ws-proxy";
    platforms = lib.platforms.linux;
  };
})
