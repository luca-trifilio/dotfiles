#!/bin/bash
# Maps macOS app names to sketchybar-app-font glyph escape codes.
# Usage: source ./icon_map_fn.sh; icon_map "Safari"; echo "$icon_result"
# Or: ./icon_map_fn.sh "Safari"

icon_map() {
  case "$1" in
    "Activity Monitor") icon_result=":activity_monitor:" ;;
    "Alacritty") icon_result=":alacritty:" ;;
    "Alfred") icon_result=":alfred:" ;;
    "App Store") icon_result=":app_store:" ;;
    "Arc") icon_result=":arc:" ;;
    "Bear") icon_result=":bear:" ;;
    "Bitwarden") icon_result=":bit_warden:" ;;
    "Blender") icon_result=":blender:" ;;
    "Brave Browser") icon_result=":brave_browser:" ;;
    "Calculator") icon_result=":calculator:" ;;
    "Calendar" | "Fantastical" | "Cron" | "Notion Calendar") icon_result=":calendar:" ;;
    "calibre") icon_result=":calibre:" ;;
    "ChatGPT") icon_result=":openai:" ;;
    "Claude") icon_result=":claude:" ;;
    "Chromium" | "Google Chrome" | "Google Chrome Canary") icon_result=":google_chrome:" ;;
    "Code" | "Code - Insiders") icon_result=":code:" ;;
    "Cursor") icon_result=":cursor:" ;;
    "DataGrip") icon_result=":datagrip:" ;;
    "DaVinci Resolve") icon_result=":davinciresolve:" ;;
    "Default") icon_result=":default:" ;;
    "Discord" | "Discord Canary" | "Discord PTB") icon_result=":discord:" ;;
    "Docker" | "Docker Desktop") icon_result=":docker:" ;;
    "Emacs") icon_result=":emacs:" ;;
    "FaceTime") icon_result=":face_time:" ;;
    "Figma") icon_result=":figma:" ;;
    "Final Cut Pro") icon_result=":final_cut_pro:" ;;
    "Finder" | "访达") icon_result=":finder:" ;;
    "Firefox") icon_result=":firefox:" ;;
    "Firefox Developer Edition" | "Firefox Nightly") icon_result=":firefox_developer_edition:" ;;
    "Fork") icon_result=":fork:" ;;
    "Ghostty") icon_result=":ghostty:" ;;
    "GitHub Desktop") icon_result=":git_hub:" ;;
    "Godot") icon_result=":godot:" ;;
    "GoLand") icon_result=":goland:" ;;
    "Hyper") icon_result=":hyper:" ;;
    "IntelliJ IDEA") icon_result=":idea:" ;;
    "IINA") icon_result=":iina:" ;;
    "Inkscape") icon_result=":inkscape:" ;;
    "iTerm" | "iTerm2") icon_result=":iterm:" ;;
    "Joplin") icon_result=":joplin:" ;;
    "KeePassXC") icon_result=":kee_pass_x_c:" ;;
    "Keynote") icon_result=":keynote:" ;;
    "kitty") icon_result=":kitty:" ;;
    "League of Legends") icon_result=":league_of_legends:" ;;
    "Linear") icon_result=":linear:" ;;
    "LM Studio") icon_result=":lm_studio:" ;;
    "Logic Pro") icon_result=":logicpro:" ;;
    "Logseq") icon_result=":logseq:" ;;
    "Mail" | "Canary Mail" | "HEY" | "Mailspring" | "Superhuman" | "Spark" | "邮件") icon_result=":mail:" ;;
    "Maps" | "Google Maps") icon_result=":maps:" ;;
    "Messages" | "信息") icon_result=":messages:" ;;
    "Microsoft Edge") icon_result=":microsoft_edge:" ;;
    "Microsoft Excel") icon_result=":microsoft_excel:" ;;
    "Microsoft Outlook") icon_result=":microsoft_outlook:" ;;
    "Microsoft PowerPoint") icon_result=":microsoft_power_point:" ;;
    "Microsoft Teams" | "Microsoft Teams (work or school)") icon_result=":microsoft_teams:" ;;
    "Microsoft Word") icon_result=":microsoft_word:" ;;
    "Miro") icon_result=":miro:" ;;
    "mpv") icon_result=":mpv:" ;;
    "Music" | "Musica" | "音乐" | "Musique" | "Youtube Music" | "YouTube Music") icon_result=":music:" ;;
    "Neovide" | "neovide") icon_result=":neovide:" ;;
    "Neovim" | "neovim" | "nvim") icon_result=":neovim:" ;;
    "Notion") icon_result=":notion:" ;;
    "Nova") icon_result=":nova:" ;;
    "Numbers") icon_result=":numbers:" ;;
    "OBS") icon_result=":obsstudio:" ;;
    "Obsidian") icon_result=":obsidian:" ;;
    "OmniFocus") icon_result=":omni_focus:" ;;
    "1Password") icon_result=":one_password:" ;;
    "Opera") icon_result=":opera:" ;;
    "OrbStack") icon_result=":orbstack:" ;;
    "Pages") icon_result=":pages:" ;;
    "Parallels Desktop") icon_result=":parallels:" ;;
    "Preview" | "预览" | "Skim" | "Aperçu") icon_result=":pdf:" ;;
    "PDF Expert") icon_result=":pdf_expert:" ;;
    "Photos") icon_result=":photos:" ;;
    "PhpStorm") icon_result=":php_storm:" ;;
    "Plex") icon_result=":plex:" ;;
    "Plexamp") icon_result=":plexamp:" ;;
    "Podcasts" | "播客") icon_result=":podcasts:" ;;
    "Postman") icon_result=":postman:" ;;
    "Proton Mail" | "Proton Mail Bridge") icon_result=":proton_mail:" ;;
    "PyCharm") icon_result=":pycharm:" ;;
    "Reeder") icon_result=":reeder5:" ;;
    "Reminders" | "提醒事项") icon_result=":reminders:" ;;
    "Rider" | "JetBrains Rider") icon_result=":rider:" ;;
    "Rio") icon_result=":rio:" ;;
    "Safari" | "Safari Technology Preview") icon_result=":safari:" ;;
    "Sequel Ace") icon_result=":sequel_ace:" ;;
    "Signal") icon_result=":signal:" ;;
    "Sketch") icon_result=":sketch:" ;;
    "Skype") icon_result=":skype:" ;;
    "Slack") icon_result=":slack:" ;;
    "Spotify") icon_result=":spotify:" ;;
    "Sublime Text") icon_result=":sublime_text:" ;;
    "Tana") icon_result=":tana:" ;;
    "Telegram") icon_result=":telegram:" ;;
    "Terminal" | "终端") icon_result=":terminal:" ;;
    "Things" | "Microsoft To Do") icon_result=":things:" ;;
    "Thunderbird") icon_result=":thunderbird:" ;;
    "TickTick") icon_result=":tick_tick:" ;;
    "Todoist") icon_result=":todoist:" ;;
    "Tower") icon_result=":tower:" ;;
    "Transmit") icon_result=":transmit:" ;;
    "Typora") icon_result=":text:" ;;
    "UTM") icon_result=":utm:" ;;
    "Vim" | "MacVim" | "VimR") icon_result=":vim:" ;;
    "Vivaldi") icon_result=":vivaldi:" ;;
    "VLC") icon_result=":vlc:" ;;
    "VMware Fusion") icon_result=":vmware_fusion:" ;;
    "VSCodium") icon_result=":vscodium:" ;;
    "Warp") icon_result=":warp:" ;;
    "WebStorm") icon_result=":web_storm:" ;;
    "WeChat" | "微信") icon_result=":wechat:" ;;
    "WezTerm") icon_result=":wezterm:" ;;
    "WhatsApp") icon_result=":whats_app:" ;;
    "Xcode") icon_result=":xcode:" ;;
    "Zed") icon_result=":zed:" ;;
    "Zen Browser" | "Zen") icon_result=":zen_browser:" ;;
    "zoom.us") icon_result=":zoom:" ;;
    "Zotero") icon_result=":zotero:" ;;
    *) icon_result=":default:" ;;
  esac
}

# When invoked directly (not sourced), run the lookup and print result.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  icon_map "$1"
  echo "$icon_result"
fi
