return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    branch = "master", -- Use the legacy branch for compatibility
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "windwp/nvim-ts-autotag",
    },
    cmd = { "TSUpdateSync" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>", desc = "Decrement selection", mode = "x" },
    },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "css",
        "diff",
        "dockerfile",
        "git_config",
        "go",
        "gomod",
        "graphql",
        "hcl",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "luadoc",
        "luap",
        "make",
        "markdown",
        "markdown_inline",
        "nginx",
        "python",
        "query",
        "regex",
        "rust",
        "scss",
        "sql",
        "svelte",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
        "yaml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    opts = {},
  },
}
