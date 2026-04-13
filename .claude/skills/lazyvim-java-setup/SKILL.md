---
name: lazyvim-java-setup
description: Use when configuring Java development in LazyVim/Neovim, setting up nvim-jdtls, inlay hints, code lens, or troubleshooting Java LSP issues.
---

# LazyVim Java Setup

## Current state
- Extra enabled: `lazyvim.plugins.extras.lang.java`
- Plugin: nvim-jdtls (included by LazyVim, not manually chosen)
- Config file: `nvim/lua/plugins/java.lua`
- Projects: Gradle + Spring Boot, Java 21
- jdtls version: 1.57.0-SNAPSHOT
- Persistent workspace: `~/.cache/nvim/jdtls/<project>/workspace` (already managed by LazyVim, not `/tmp`)
- Lombok: already configured automatically by LazyVim via javaagent

## Current config (java.lua)

```lua
return {
  "mfussenegger/nvim-jdtls",
  opts = {
    settings = {
      java = {
        inlayHints = {
          parameterNames = {
            enabled = "all",
          },
        },
        referencesCodeLens = {
          enabled = false,
        },
        implementationsCodeLens = {
          enabled = false,
        },
      },
    },
  },
}
```

## Useful jdtls commands
- `:Lazy reload nvim-jdtls` + Neovim restart → apply new config
- `:JdtWipeDataAndRestart` → clear jdtls cache (useful when LSP gets stuck)
- `:JdtUpdateConfig` → reload Gradle dependencies after editing build.gradle
- `:JdtCompile` → compile the workspace without leaving Neovim
- `<Space>cC` → manual code lens refresh

## Code lens
- Controlled by `referencesCodeLens` and `implementationsCodeLens` in java.lua
- Highlight group: `LspCodeLens` → Dracula uses cyan (#00D9FF), very visible
- Currently disabled — re-enable with `enabled = true` when a style is decided

## Inlay hints
- Highlight group: `LspInlayHint` → Dracula: fg=#969696, bg=#2f3146 (subtle gray)
- Configured with `parameterNames.enabled = "all"` — shows parameter names inline

## Applying config changes
`:e` is not enough — lazy.nvim must reload the plugin spec:
1. `:Lazy reload nvim-jdtls`
2. Restart Neovim (more reliable)

## Gradle builds from Neovim
Use the floating terminal (`<C-/>`) and run:
```bash
./gradlew bootJar -x test          # fast jar without tests
./gradlew build                    # full build
./gradlew spotlessApply            # fix formatting (required by check/test/bootJar)
```
Note: `check`, `test`, and `bootJar` all depend on `spotlessCheck` — if formatting is wrong, the build fails before compiling.

## Bootstrap on a new machine
1. Install Neovim >= 0.12
2. Install Java 21 (required for jdtls)
3. Clone dotfiles + run stow
4. Open Neovim → lazy.nvim installs everything automatically
5. Open a `.java` file → jdtls attaches and indexes the project
