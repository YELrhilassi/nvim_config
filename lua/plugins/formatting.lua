return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "Format",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        python = { "isort", "black" },
        go = { "goimports", "gofmt" },
        rust = { "rustfmt" },
        bash = { "shfmt" },
        sh = { "shfmt" },
      },
      format_on_save = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_fallback = true,
      },
    },
  },
}
