{
  programs.waybar = {
    enable = true;

    systemd.enable = true;
    systemd.targets = [ "hyprland-session.target" ];

    settings = {
      mainBar = {
        layer = "top";
        height = 42;
        spacing = 6;

        modules-left = [
          "group/distro-group"
          "group/storage"
          "group/system"
        ];

        modules-center = [
          "power-profiles-daemon"
          "hyprland/workspaces"
          "idle_inhibitor"
        ];

        modules-right = [
          "group/audio"
          "group/connections"
          "battery"
          "clock"
          "group/tray-group"
        ];

        "battery" = {
          interval = 60;

          states = {
            warning = 30;
            critical = 15;
          };

          format = "{icon} <span size='11pt'>{capacity}%</span>";
          format-full = "{icon} <span size='11pt'>{capacity}%</span>";
          format-charging = "<span size='12pt'>󱐌</span> <span size='11pt'>{capacity}%</span>";
          format-plugged = "<span size='12pt'></span> <span size='11pt'>{capacity}%</span>";
          format-alt = "{icon} <span size='11pt'>{time}</span>";

          tooltip-format = ''
            {timeTo}

            󰠠  Usage: {power:0.1f}W
            󱤅  Condition: {health}%
            󱍸  Total: {cycles} cycles
          '';

          format-icons = {
            default = [
              "󰂎"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
          };
        };

        "clock" = {
          timezone = "Europe/Moscow";
          format = "󰃱 <span size='11pt'>{:%H:%M }</span>";
          format-alt = "󰃱 <span size='11pt'>{:%d %B %Y}</span>";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        "network" = {
          format-wifi = "{icon}";
          format-ethernet = "";
          format-linked = "󱘖";
          format-disconnected = "󰤣";
          format-disabled = "󰤮";

          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];

          tooltip-format-disconnected = "No Connection";
          tooltip-format-disabled = "Wi-Fi is OFF";

          tooltip-format-wifi = ''
            󱄙  {essid} ({signalStrength}%)

            󰐻  Freq: {frequency}GHz
              {bandwidthDownBytes}   {bandwidthUpBytes}
          '';

          tooltip-format-ethernet = ''
            󰈀  {ifname} (Connected)
              {bandwidthDownBytes}   {bandwidthUpBytes}
          '';

          tooltip-format-linked = "󱘖 {ifname}: No IP Address";

          on-click = "nm-applet --indicator";
          on-click-right = "pkill nm-applet";
          on-scroll-up = "nmcli radio wifi on";
          on-scroll-down = "nmcli radio wifi off";
        };

        "bluetooth" = {
          format = "󰂯";
          format-connected = "󰂱";
          format-disabled = "󰂲";

          tooltip-format = "{controller_alias} {status}";
          tooltip-format-connected = "󰐻  {num_connections} Connected:\n{device_enumerate}";
          tooltip-format-enumerate-connected-battery = "󰂱  {device_alias} (󰠠  {device_battery_percentage}%)";

          on-click = "blueman-manager";
          on-click-right = "rfkill toggle bluetooth";
        };

        "custom/distro" = {
          format = "";
          tooltip = false;
        };

        "custom/terminal" = {
          format = "󰆍";
          on-click = "kitty";
          tooltip = false;
        };

        "custom/office" = {
          format = "󰏆";
          on-click = "onlyoffice-desktopeditors";
          tooltip = false;
        };

        "custom/browser" = {
          format = "";
          on-click = "zen-beta";
          tooltip = false;
        };

        "group/distro-group" = {
          orientation = "horizontal";

          drawer = {
            transition-duration = 650;
            transition-left-to-right = true;
          };

          modules = [
            "custom/distro"
            "custom/terminal"
            "custom/office"
            "custom/browser"
          ];
        };

        "group/storage" = {
          orientation = "horizontal";
          modules = [
            "disk"
            "memory"
          ];
        };

        "group/system" = {
          orientation = "horizontal";
          modules = [
            "temperature"
            "cpu"
          ];
        };

        "group/audio" = {
          orientation = "horizontal";

          drawer = {
            transition-duration = 650;
            transition-left-to-right = false;
          };

          modules = [
            "pulseaudio"
            "pulseaudio/slider"
            "pulseaudio#microphone"
          ];
        };

        "group/connections" = {
          orientation = "horizontal";

          drawer = {
            transition-duration = 500;
            transition-left-to-right = false;
          };

          modules = [
            "network"
            "bluetooth"
          ];
        };

        "group/tray-group" = {
          orientation = "horizontal";

          drawer = {
            transition-duration = 500;
            transition-left-to-right = false;
          };

          modules = [
            "custom/tray-arrow"
            "tray"
          ];
        };

        "idle_inhibitor" = {
          format = "{icon}";

          format-icons = {
            activated = "󰛨";
            deactivated = "󰛩";
          };

          tooltip-format-activated = "System Focused";
          tooltip-format-deactivated = "Normal Mode";
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "󰓅   {profile}\n󰒓   {driver}";

          format-icons = {
            default = "";
            performance = "";
            balanced = "󰶘";
            power-saver = "";
          };
        };

        "disk" = {
          tooltip = false;
          interval = 3600;
          path = "/";
          format = "󱙋";
          format-alt = "󱙋 <span size='11pt'>{used}</span>";

          states = {
            warning = 80;
            critical = 90;
          };
        };

        "memory" = {
          tooltip = false;
          interval = 15;
          format = "󰍛";
          format-alt = "󰍛 <span size='11pt'>{used}</span>";

          states = {
            warning = 75;
            critical = 85;
          };
        };

        "cpu" = {
          tooltip = false;
          interval = 10;
          format = "󰻠";
          format-alt = "󰻠 <span size='11pt'>{usage}%</span>";

          states = {
            warning = 75;
            critical = 90;
          };
        };

        "temperature" = {
          tooltip = false;
          interval = 10;
          thermal-zone = 8;
          critical-threshold = 80;

          format = "{icon}";
          format-alt = "{icon} <span size='11pt'>{temperatureC}°C</span>";
          format-critical = "<span size='12pt'>󱗗 </span><span size='11pt'>{temperatureC}°C</span>";

          format-icons = [
            ""
            ""
            ""
          ];
        };

        "custom/tray-arrow" = {
          format = "{icon}";
          tooltip = false;

          format-icons = {
            notification = "󱅫";
            none = "󰏖";
            dnd-notification = "󰂠";
            dnd-none = "󰪓";
            inhibited-notification = "󰂛";
            inhibited-none = "󰪑";
            dnd-inhibited-notification = "󰂛";
            dnd-inhibited-none = "󰪑";
          };

          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };

        "tray" = {
          icon-size = 16;
          spacing = 10;
          show-passive-items = true;

          icons = {
            blueman = "/usr/share/icons/Tela-circle-dark/scalable/apps/blueman.svg";
            discord = "/usr/share/icons/Tela-circle-dark/scalable/apps/discord.svg";
            spotify = "/usr/share/icons/Tela-circle/scalable/apps/spotify.svg";
            steam = "/usr/share/icons/Tela-circle-dark/scalable/apps/steam.svg";
          };
        };

        "hyprland/workspaces" = {
          format = "{icon} {windows}";
          on-click = "activate";

          persistent-workspaces = {
            "*" = 5;
          };

          window-rewrite-default = "󰊠";

          window-rewrite = {
            # Work
            kitty = "󰆍";
            onlyoffice = "󰏆";
            firefox = "";
            code = "󰨞";
            azahar = "";
            obsidian = "󰹕";
            mousepad = "󱓧";

            # Apps
            discord = "";
            spotify = "";
            "org.kde.kdeconnect.app" = "󰦉";
            "org.qbittorrent.qBittorrent" = "󰘿";

            # Graphics & Visual
            "xdg-desktop-portal-gtk" = "";
            thunar = "";
            yazi = "󰇥";
            imv = "󰄄";
            swappy = "󰄄";
            "org.gnome.FileRoller" = "";
            vlc = "󰕼";
            mpv = "󰕼";

            # System
            "blueman-manager" = "";
            pavucontrol = "󱕂";
            "nm-connection-editor" = "󰐻";

            # Tool
            "nwg-look" = "󰒓";
            qt5ct = "󰒓";
            qt6ct = "󰒓";
            designer = "󰒓";
            linguist = "󰒓";
            assistant = "󰒓";
            pixeltool = "󰒓";
            qdbusviewer = "󰒓";
          };

          format-icons = {
            active = "󰮯";
            special = "󱁂";
            default = "󰊠";
            urgent = "󰧵";
            empty = "";
          };

          show-special = true;
          all-outputs = true;
        };

        "pulseaudio" = {
          format = "{icon}";
          format-muted = "";

          format-icons = {
            headphone = "󰋋";
            headset = "󰋋";
            hands-free = "󰋋";

            default = [
              ""
              ""
              ""
            ];
          };

          on-click = "pavucontrol";
          tooltip-format = "Output: {volume}%";
        };

        "pulseaudio#microphone" = {
          format = "{format_source}";
          format-source = "";
          format-source-muted = "";
        };

        "pulseaudio/slider" = {
          min = 0;
          max = 100;
          orientation = "horizontal";
        };
      };
    };

    style = ''
      @import "tokens/colors.css";
      @import "tokens/state.css";
      @import "tokens/workspace.css";
      @import "tokens/widget.css";
      @import "tokens/batt-clock.css";
      @import "tokens/slider.css";

      * {
        margin: 0;
        padding: 0;
        min-height: 0px;
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
      }

      window#waybar {
        background: transparent;
      }
    '';
  };

  xdg.configFile."waybar/tokens".source = ./tokens;
}
