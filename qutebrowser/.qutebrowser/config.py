config.load_autoconfig(True)

# Tab switching with Cmd+number (Alt+number conflicts with Aerospace)
for i in range(1, 10):
    config.bind(f'<Meta+{i}>', f'tab-focus {i}')

# Bitwarden userscript keybindings
config.bind(',p', 'spawn --userscript qute-bitwarden')
config.bind(',P', 'spawn --userscript qute-bitwarden --password-only')
config.bind(',u', 'spawn --userscript qute-bitwarden --username-only')
config.bind(',t', 'spawn --userscript qute-bitwarden --totp')
