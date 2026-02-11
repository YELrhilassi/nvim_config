return {
  -- Theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          sidebars = "dark",
          floats = "dark",
        },
      })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- Better `vim.notify`
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local icons = {
        diagnostics = { Error = " ", Warn = " ", Hint = " ", Info = " " },
        git = { added = " ", modified = " ", removed = " " },
      }
      return {
        options = {
          theme = "tokyonight",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
          },
          lualine_x = {
             {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return " " .. os.date("%R")
            end,
          },
        },
      }
    end,
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete Other Buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    },
    opts = {
      options = {
        close_command = function(n) require("mini.bufremove").delete(n, false) end,
        right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = { Error = " ", Warn = " ", Hint = " ", Info = " " }
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "oil",
            text = "Oil",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd("BufAdd", {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },

  -- Highly experimental UI for messages, cmdline and popupmenu
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
      },
      -- Disable notify handling in Noice to let nvim-notify handle it
      notify = {
        enabled = false,
      },
    },
    keys = {
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
    },
  },

  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      easing_function = "quadratic",
      pre_hook = nil,
      post_hook = nil,
      performance_mode = false,
    },
  },

  -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function()
      local logo = [[
███╗   ██╗███████╗██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║  ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║  ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = {
          -- this is taken care of by lualine
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
          center = {
            { action = "ene | startinsert", desc = " New file", icon = " ", key = "n" },
            { action = "Telescope find_files", desc = " Find file", icon = " ", key = "f" },
            { action = "Telescope live_grep", desc = " Find text", icon = " ", key = "g" },
            { action = "Telescope oldfiles", desc = " Recent files", icon = " ", key = "r" },
            { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
            { action = "qa", desc = " Quit", icon = " ", key = "q" },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      return opts
    end,
  },

  -- Better StatusColumn (Gutter)
  {
    "luukvbaal/statuscol.nvim",
    opts = function()
      local builtin = require("statuscol.builtin")
      return {
        setopt = true,
        -- Override the default segments to be clean
        segments = {
          -- Fold column (clean icons only, no numbers)
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          -- Sign column (git signs, diagnostics)
          { text = { "%s" }, click = "v:lua.ScSa" },
          -- Line number
          { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
        },
      }
    end,
  },
  
  -- Icons
  { "echasnovski/mini.icons", opts = {} },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
}
