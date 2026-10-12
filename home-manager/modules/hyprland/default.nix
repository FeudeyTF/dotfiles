{
  lib,
  ...
}:

let
  inherit (lib) concatMap range;
  inherit (lib.generators) mkLuaInline toLua;

  mainMod = "SUPER";

  black = "rgba(11111bff)";
  accent = "rgba(b4befeff)";
  font = "CommitMono Nerd Font";

  terminal = "kitty";
  fileManager = ''kitty -e --class mc "mc"'';
  menu = "kitty -e fsel --detach";

  touchpad = "elan050a:01-04f3:3158-touchpad";
  wired = "beken-usb-gaming-mouse";
  wireless = "beken-2.4g-wireless-device";

  raw = mkLuaInline;

  args = values: {
    _args = values;
  };

  curve =
    name: definition:
    args [
      name
      (raw (toLua { } definition))
    ];

  animation =
    definition:
    args [
      (raw (toLua { } definition))
    ];

  env =
    name: value:
    args [
      name
      value
    ];

  exec = command: raw "hl.dsp.exec_cmd(${toLua { } command})";

  focus = options: raw "hl.dsp.focus(${toLua { } options})";

  moveWindow = options: raw "hl.dsp.window.move(${toLua { } options})";

  resizeWindow = options: raw "hl.dsp.window.resize(${toLua { } options})";

  floatWindow = options: raw "hl.dsp.window.float(${toLua { } options})";

  windowAction = action: raw "hl.dsp.window.${action}()";

  bind =
    key: action:
    args [
      key
      action
    ];

  bindOptions =
    key: action: options:
    args [
      key
      action
      options
    ];

  key = modifiers: button: lib.concatStringsSep " + " ([ mainMod ] ++ modifiers ++ [ button ]);

  mod = button: key [ ] button;

  modShift = button: key [ "SHIFT" ] button;

  modCtrl = button: key [ "CTRL" ] button;

  modAlt = button: key [ "ALT" ] button;

  modShiftCtrl = button: key [ "SHIFT" "CTRL" ] button;

  workspaceKeys = [
    "ampersand"
    "bracketleft"
    "braceleft"
    "braceright"
    "parenleft"
    "equal"
    "asterisk"
    "parenright"
    "plus"
    "bracketright"
  ];

  workspaceBinds = concatMap (
    workspace:
    let
      workspaceKey = builtins.elemAt workspaceKeys (workspace - 1);
      numberKey = if workspace == 10 then "0" else toString workspace;
    in
    [
      # switch workspace
      (bind (mod workspaceKey) (focus {
        workspace = workspace;
      }))

      # move workspace
      (bind (modShift workspaceKey) (moveWindow {
        workspace = workspace;
      }))

      # move workspace without switch
      (bind (modAlt numberKey) (moveWindow {
        workspace = workspace;
        follow = false;
      }))
    ]
  ) (range 1 10);

  lockedRepeatingBind =
    key: command:
    bindOptions key (exec command) {
      locked = true;
      repeating = true;
    };

  lockedBind =
    key: command:
    bindOptions key (exec command) {
      locked = true;
    };

in
{
  imports = [
    ./hyprpaper.nix
    ./hyprshot.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    package = null;
    portalPackage = null;

    settings = {
      monitor = [
        {
          output = "";
          mode = "highres";
          position = "auto";
          scale = 1;
          bitdepth = 10;
        }

        {
          output = "HDMI-A-1";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];

      env = [
        # XDG
        (env "XDG_CURRENT_DESKTOP" "Hyprland")
        (env "XDG_SESSION_TYPE" "wayland")
        (env "XDG_SESSION_DESKTOP" "Hyprland")

        # Qt
        (env "QT_SCALE_FACTOR" "1")
        (env "QT_QPA_PLATFORM" "wayland")
        (env "QT_WAYLAND_DISABLE_WINDOWDECORATION" "1")
        (env "QT_QPA_PLATFORMTHEME" "gtk3")

        # Nvidia
        (env "__GLX_VENDOR_LIBRARY_NAME" "nvidia")
        (env "LIBVA_DRIVER_NAME" "nvidia")
        (env "__GL_VRR_ALLOWED" "1")
        (env "WLR_DRM_NO_ATOMIC" "1")
        (env "WLR_NO_HARDWARE_CURSORS" "1")

        # Cursor
        (env "HYPRCURSOR_SIZE" "24")
        (env "XCURSOR_SIZE" "24")
        (env "QT_CURSOR_SIZE" "24")

        # GDK
        (env "GDK_BACKEND" "wayland")
        (env "GDK_SCALE" "1")

        # Firefox
        (env "MOZ_ENABLE_WAYLAND" "1")

        # Slurp
        (env "SLURP_ARGS" "-b 00000066 -c ff0000 -d")
      ];

      config = {
        debug = {
          disable_logs = false;
          enable_stdout_logs = true;
        };

        input = {
          kb_layout = "us,ru";
          kb_variant = "dvp";
          kb_options = "grp:rctrl_toggle";

          follow_mouse = 1;
          sensitivity = 0;

          touchpad = {
            natural_scroll = false;
          };
        };

        general = {
          border_size = 0;
          gaps_in = 5;
          gaps_out = 8;

          snap = {
            enabled = true;
            window_gap = 5;
            monitor_gap = 5;
          };

          col = {
            active_border = black;
            inactive_border = accent;
          };
        };

        animations = {
          enabled = true;
        };

        decoration = {
          rounding = 10;
          rounding_power = 2;

          active_opacity = 0.88;
          inactive_opacity = 0.88;
          fullscreen_opacity = 1.0;

          shadow = {
            enabled = true;
            range = 15;
            render_power = 5;
            color = "rgba(00000080)";
          };

          blur = {
            enabled = true;
            size = 3;
            passes = 3;
            new_optimizations = true;
            ignore_opacity = true;
            xray = true;
            popups = true;
          };
        };

        dwindle = {
          preserve_split = true;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          font_family = font;
          force_default_wallpaper = 0;
          animate_manual_resizes = true;
          focus_on_activate = true;
          middle_click_paste = false;
        };

        xwayland = {
          force_zero_scaling = true;
        };

        cursor = {
          inactive_timeout = 5;
          no_warps = true;
          hide_on_key_press = false;
        };

        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };
      };

      # Curves

      curve = [
        (curve "easeOutQuint" {
          type = "bezier";
          points = [
            [
              0.23
              1.0
            ]
            [
              0.32
              1.0
            ]
          ];
        })

        (curve "easeInOutCubic" {
          type = "bezier";
          points = [
            [
              0.65
              0.05
            ]
            [
              0.36
              1.0
            ]
          ];
        })

        (curve "linear" {
          type = "bezier";
          points = [
            [
              0.0
              0.0
            ]
            [
              1.0
              1.0
            ]
          ];
        })

        (curve "almostLinear" {
          type = "bezier";
          points = [
            [
              0.5
              0.5
            ]
            [
              0.75
              1.0
            ]
          ];
        })

        (curve "quick" {
          type = "bezier";
          points = [
            [
              0.15
              0.0
            ]
            [
              0.1
              1.0
            ]
          ];
        })

        (curve "easy" {
          type = "spring";
          mass = 1.0;
          stiffness = 238.1191;
          dampening = 24.21279333;
        })
      ];

      # Animations

      animation = [
        (animation {
          leaf = "global";
          enabled = true;
          speed = 10.0;
          bezier = "default";
        })

        (animation {
          leaf = "border";
          enabled = true;
          speed = 5.39;
          bezier = "easeOutQuint";
        })

        (animation {
          leaf = "windows";
          enabled = true;
          speed = 4.79;
          spring = "easy";
        })

        (animation {
          leaf = "windowsIn";
          enabled = true;
          speed = 4.1;
          spring = "easy";
          style = "popin 87%";
        })

        (animation {
          leaf = "windowsOut";
          enabled = true;
          speed = 1.49;
          bezier = "linear";
          style = "popin 87%";
        })

        (animation {
          leaf = "fadeIn";
          enabled = true;
          speed = 1.73;
          bezier = "almostLinear";
        })

        (animation {
          leaf = "fadeOut";
          enabled = true;
          speed = 1.46;
          bezier = "almostLinear";
        })

        (animation {
          leaf = "fade";
          enabled = true;
          speed = 3.03;
          bezier = "quick";
        })

        (animation {
          leaf = "layers";
          enabled = true;
          speed = 3.81;
          bezier = "easeOutQuint";
        })

        (animation {
          leaf = "layersIn";
          enabled = true;
          speed = 4.0;
          bezier = "easeOutQuint";
          style = "fade";
        })

        (animation {
          leaf = "layersOut";
          enabled = true;
          speed = 1.5;
          bezier = "linear";
          style = "fade";
        })

        (animation {
          leaf = "fadeLayersIn";
          enabled = true;
          speed = 1.79;
          bezier = "almostLinear";
        })

        (animation {
          leaf = "fadeLayersOut";
          enabled = true;
          speed = 1.39;
          bezier = "almostLinear";
        })

        (animation {
          leaf = "workspaces";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        })

        (animation {
          leaf = "workspacesIn";
          enabled = true;
          speed = 1.21;
          bezier = "almostLinear";
          style = "fade";
        })

        (animation {
          leaf = "workspacesOut";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        })

        (animation {
          leaf = "zoomFactor";
          enabled = true;
          speed = 7.0;
          bezier = "quick";
        })
      ];
      gesture = {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      };

      on = args [
        "hyprland.start"

        (raw ''
          function()
            hl.exec_cmd("waybar")
            hl.exec_cmd("hypridle")
            hl.exec_cmd("hyprpaper")
          end
        '')
      ];

      bind = [
        # Hotkeys
        (bind (mod "Q") (exec terminal))
        (bind (mod "E") (exec fileManager))
        (bind (mod "B") (exec "zen-beta"))
        (bind (modShift "F") (exec "zen-beta --private-window"))
        (bind (mod "R") (exec menu))

        # Screenshots
        (bind (mod "PRINT") (exec "hyprshot -m window"))

        (bind (modShift "PRINT") (exec "hyprshot -m output"))

        (bind "PRINT" (exec "hyprshot -m region"))

        # Windows
        (bind (mod "F") (windowAction "fullscreen"))

        (bind (modShift "W") (floatWindow {
          action = "toggle";
        }))

        (bind (mod "C") (windowAction "close"))

        # Move to a relative workspace
        (bind (modCtrl "Left") (moveWindow {
          workspace = "r-1";
        }))

        (bind (modCtrl "Right") (moveWindow {
          workspace = "r+1";
        }))

        (bind (modCtrl "H") (moveWindow {
          workspace = "r-1";
        }))

        (bind (modCtrl "L") (moveWindow {
          workspace = "r+1";
        }))

        # Move to a free workspace
        (bind (modCtrl "Down") (focus {
          workspace = "empty";
        }))

        (bind (modCtrl "J") (focus {
          workspace = "empty";
        }))

        # Existing workspace
        (bind (mod "mouse_up") (focus {
          workspace = "e-1";
        }))

        (bind (mod "mouse_down") (focus {
          workspace = "e+1";
        }))

        # Dragging the window with the mouse
        (bindOptions (mod "mouse:272") (raw "hl.dsp.window.drag()") {
          mouse = true;
        })

        # Changing the window size with the mouse
        (bindOptions (mod "mouse:273") (raw "hl.dsp.window.resize()") {
          mouse = true;
        })

        # Scaling
        (bindOptions (modShift "mouse:272") (exec "$scripts/zoom 0.5") {
          repeating = true;
        })

        # Sound
        (lockedRepeatingBind "XF86AudioRaiseVolume" "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")

        (lockedRepeatingBind "XF86AudioLowerVolume" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")

        (lockedRepeatingBind "XF86AudioMute" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")

        (lockedRepeatingBind "XF86AudioMicMute" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")

        # Brightness
        (lockedRepeatingBind "XF86MonBrightnessDown" "$scripts/backlight down")

        (lockedRepeatingBind "XF86MonBrightnessUp" "$scripts/backlight up")

        (bind (modAlt "D") (exec "$scripts/backlight down"))

        (bind (modAlt "U") (exec "$scripts/backlight up"))

        # Media
        (lockedBind "XF86AudioNext" "playerctl next")

        (lockedBind "XF86AudioPause" "playerctl play-pause")

        (lockedBind "XF86AudioPlay" "playerctl play-pause")

        (lockedBind "XF86AudioPrev" "playerctl previous")

        # Focus
        (bind (mod "Left") (focus {
          direction = "left";
        }))

        (bind (mod "Down") (focus {
          direction = "down";
        }))

        (bind (mod "Up") (focus {
          direction = "up";
        }))

        (bind (mod "Right") (focus {
          direction = "right";
        }))

        (bind (mod "H") (focus {
          direction = "left";
        }))

        (bind (mod "J") (focus {
          direction = "down";
        }))

        (bind (mod "K") (focus {
          direction = "up";
        }))

        (bind (mod "L") (focus {
          direction = "right";
        }))

        # Move window
        (bind (modShiftCtrl "Left") (moveWindow {
          direction = "left";
        }))

        (bind (modShiftCtrl "Down") (moveWindow {
          direction = "down";
        }))

        (bind (modShiftCtrl "Up") (moveWindow {
          direction = "up";
        }))

        (bind (modShiftCtrl "Right") (moveWindow {
          direction = "right";
        }))

        (bind (modShiftCtrl "H") (moveWindow {
          direction = "left";
        }))

        (bind (modShiftCtrl "J") (moveWindow {
          direction = "down";
        }))

        (bind (modShiftCtrl "K") (moveWindow {
          direction = "up";
        }))

        (bind (modShiftCtrl "L") (moveWindow {
          direction = "right";
        }))

        # Resize window
        (bindOptions (modShift "Left")
          (resizeWindow {
            x = -10;
            y = 0;
            relative = true;
          })
          {
            repeating = true;
          }
        )

        (bindOptions (modShift "Down")
          (resizeWindow {
            x = 0;
            y = 10;
            relative = true;
          })
          {
            repeating = true;
          }
        )

        (bindOptions (modShift "Up")
          (resizeWindow {
            x = 0;
            y = -10;
            relative = true;
          })
          {
            repeating = true;
          }
        )

        (bindOptions (modShift "Right")
          (resizeWindow {
            x = 10;
            y = 0;
            relative = true;
          })
          {
            repeating = true;
          }
        )

        (bindOptions (modShift "H")
          (resizeWindow {
            x = -10;
            y = 0;
            relative = true;
          })
          {
            repeating = true;
          }
        )

        (bindOptions (modShift "J")
          (resizeWindow {
            x = 0;
            y = 10;
            relative = true;
          })
          {
            repeating = true;
          }
        )

        (bindOptions (modShift "K")
          (resizeWindow {
            x = 0;
            y = -10;
            relative = true;
          })
          {
            repeating = true;
          }
        )

        (bindOptions (modShift "L")
          (resizeWindow {
            x = 10;
            y = 0;
            relative = true;
          })
          {
            repeating = true;
          }
        )
      ]
      ++ workspaceBinds;

      window_rule = [
        {
          name = "zen-file-upload";

          match = {
            class = "zen";
            title = "File Upload";
          };

          float = true;
          center = true;
          size = "595 405";
        }

        # qView
        {
          name = "qview-default";

          match = {
            class = "com.interversehq.qView";
          };

          float = true;
          center = true;
          size = "1275 770";
        }

        {
          name = "qview-delete";

          match = {
            class = "com.interversehq.qView";
            title = "Delete";
          };

          float = true;
          center = true;
          size = "750 185";
        }

        # MPV
        {
          name = "mpv-default";

          match = {
            class = "mpv";
          };

          float = true;
          center = true;
          size = "1275 770";
        }

		 # fsel
        {
          name = "fsel";

          match = {
            title = "fsel";
          };

          float = true;
          center = true;
          size = "595 405";
        }

        # OBS Studio
        {
          name = "obs-filters";

          match = {
            class = "com.obsproject.Studio";
            title = "Filters for(.*)";
          };

          float = true;
          center = true;
          size = "810 520";
        }

        {
          name = "obs-settings";

          match = {
            class = "com.obsproject.Studio";
            title = "Settings";
          };

          float = true;
          center = true;
          size = "1120 760";
        }

        {
          name = "obs-remux-recordings";

          match = {
            class = "com.obsproject.Studio";
            title = "Remux Recordings";
          };

          float = true;
          center = true;
          size = "760 395";
        }

        # GTK dialogs
        {
          name = "gtk-open-folder";

          match = {
            class = "xdg-desktop-portal-gtk";
            title = "Open Folder";
          };

          float = true;
          center = true;
          size = "885 570";
        }

        {
          name = "gtk-open-file";

          match = {
            class = "xdg-desktop-portal-gtk";
            title = "Open File";
          };

          float = true;
          center = true;
          size = "885 570";
        }

        {
          name = "gtk-save-as";

          match = {
            class = "xdg-desktop-portal-gtk";
            title = "Save As";
          };

          float = true;
          center = true;
          size = "985 580";
        }

        {
          name = "metadata-editor";

          match = {
            class = "metadata-editor";
          };

          float = true;
          center = true;
        }

        {
          name = "export-image";

          match = {
            title = "Export Image(.*)";
          };

          float = true;
          center = true;
        }

        # Hyprland share picker
        {
          name = "hyprland-share-picker";

          match = {
            class = "hyprland-share-picker";
          };

          float = true;
          center = true;
          size = "760 435";
        }
      ];

      layer_rule = [
        {
          name = "hyprpaper-fade";

          match = {
            namespace = "hyprpaper";
          };

          animation = "fadeLayersIn";
        }

        {
          name = "notifications-alpha";

          match = {
            namespace = "notifications";
          };

          ignore_alpha = 0;
        }

        {
          name = "fsel";

          match = {
            title = "fsel";
          };

     
          ignore_alpha = 0;
        }

        {
          name = "waybar-alpha";

          match = {
            namespace = "waybar";
          };

          ignore_alpha = 0;
        }

        {
          name = "hyprpicker-no-animation";

          match = {
            namespace = "hyprpicker";
          };

          no_anim = true;
        }

        {
          name = "selection-no-animation";

          match = {
            namespace = "selection";
          };

          no_anim = true;
        }
      ];

      device = [
        {
          name = touchpad;
          sensitivity = 0.20;
        }

        {
          name = "${wired}-1";
          sensitivity = -0.75;
        }

        {
          name = "${wired}-2";
          sensitivity = -0.75;
        }

        {
          name = "${wireless}-1";
          sensitivity = -0.75;
        }

        {
          name = "${wireless}-2";
          sensitivity = -0.75;
        }
      ];
    };
  };
}
