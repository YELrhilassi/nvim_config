return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    opts = {
      provider_selector = function(_, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    },
    init = function()
      vim.o.foldcolumn = "1" -- Enable fold column so statuscol can show it
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      -- Clean fold icons for statuscol to use
      vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
    end,
    config = function(_, opts)
      local ufo = require("ufo")
      ufo.setup(opts)
      
      -- Keymaps
      vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Close all folds" })
      vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds, { desc = "Open folds except kinds" })
      vim.keymap.set("n", "zm", ufo.closeFoldsWith, { desc = "Close folds with" })
      vim.keymap.set("n", "K", function()
        local winid = ufo.peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { desc = "Peek Fold / Hover" })
    end,
  },
}
