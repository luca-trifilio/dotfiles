-- atlas.nvim — PR review + issues (GitHub/GitLab/Bitbucket/Jira) inside nvim.
-- Experimental: upstream warns of breaking changes. Only GitHub is wired up
-- (via `gh`, no token needed). Jira needs base_url + API token: add it to
-- `providers.jira` once the plugin is worth keeping, pulling the token from env
-- (SOPS loader), never inline.
-- Health check: :checkhealth atlas
return {
  {
    "emrearmagan/atlas.nvim",
    cmd = "Atlas",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>a", "", desc = "+atlas" },
      { "<leader>ap", "<cmd>Atlas pulls .<cr>", desc = "Pull requests (repo)" },
      { "<leader>aP", "<cmd>Atlas pulls github<cr>", desc = "Pull requests (GitHub)" },
      { "<leader>ai", "<cmd>Atlas issues .<cr>", desc = "Issues (repo)" },
      { "<leader>ar", "<cmd>Atlas review<cr>", desc = "Review PR" },
      { "<leader>aR", "<cmd>Atlas review .<cr>", desc = "Review current branch PR" },
      { "<leader>ao", "<cmd>Atlas open .<cr>", desc = "Open current branch PR" },
      { "<leader>ac", "<cmd>Atlas pipelines .<cr>", desc = "CI pipelines (branch)" },
      { "<leader>ab", "<cmd>Atlas browse .<cr>", desc = "Browse repo" },
      { "<leader>as", "<cmd>Atlas search .<cr>", desc = "Search" },
      { "<leader>aa", "<cmd>Atlas<cr>", desc = "Atlas commands" },
    },
    ---@type AtlasConfig
    opts = {
      ui = {
        -- LazyVim already ships snacks.nvim (see lua/plugins/snacks.lua)
        picker = "snacks",
      },
      -- A provider is only enabled when its `providers.<name>` table exists.
      -- GitHub auth comes from `gh` (honours GH_TOKEN from per-project .envrc).
      providers = {
        github = {},
      },
      pulls = {
        default_merge_method = "squash",
        -- Local clones live flat in ~/Progetti/<repo>; used for checkout/diffs.
        repo_config = {
          paths = { ["satispay-tech/*"] = "~/Progetti/*" },
        },
        github = {
          views = {
            { name = "Review requested", key = "1", layout = "compact", search = "is:pr is:open review-requested:@me archived:false" },
            { name = "My PRs", key = "2", layout = "compact", search = "is:pr is:open author:@me archived:false" },
            { name = "Involved", key = "3", layout = "compact", search = "is:pr is:open involves:@me archived:false" },
          },
        },
      },
      issues = {
        github = {
          views = {
            { name = "Assigned", key = "1", layout = "plain", search = "assignee:@me is:open" },
            { name = "Created", key = "2", layout = "compact", search = "author:@me is:open" },
          },
        },
      },
    },
  },
}
