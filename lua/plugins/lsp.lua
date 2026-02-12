return {
  -- LSP Config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    opts = {
      -- options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        -- Define clearer signs
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "●",
            [vim.diagnostic.severity.WARN] = "●",
            [vim.diagnostic.severity.HINT] = "●",
            [vim.diagnostic.severity.INFO] = "●",
          },
        },
      },
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10
      inlay_hints = {
        enabled = true,
      },
      -- add any global capabilities here
      capabilities = {},
      -- options for mason-lspconfig
      auto_install = true,
      -- list of servers to set up
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                setType = true,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
        ts_ls = {}, -- Typescript
        html = {},
        cssls = {},
        tailwindcss = {},
        svelte = {},
        -- volar = {}, -- Vue (handled via mason-tool-installer due to name mismatch)
        graphql = {},
        jsonls = {},
        yamlls = {},
        bashls = {},
        dockerls = {},
        terraformls = {},
        sqlls = {},
        marksman = {}, -- Markdown
        pyright = {},
        gopls = {},
        rust_analyzer = {},
      },
    },
    config = function(_, opts)
      -- Set up diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- LspAttach event for keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local buffer = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          
          local function map(mode, lhs, rhs, desc)
             vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
          end

          map("n", "gD", function()
            -- Handle declaration with fallback
            local params = vim.lsp.util.make_position_params()
            vim.lsp.buf_request(0, "textDocument/declaration", params, function(err, result, ctx, config)
              if err or not result or vim.tbl_isempty(result) then
                -- Fallback to definition if declaration fails
                vim.notify("Declaration not found, falling back to definition", vim.log.levels.INFO)
                vim.cmd("normal! gd")
              else
                vim.lsp.util.jump_to_location(result[1] or result, "utf-8")
              end
            end)
          end, "Goto Declaration")
          
          -- Custom Goto Definition: centers view with context
          map("n", "gd", function()
            require("telescope.builtin").lsp_definitions({
              on_list = function(options)
                -- If only one item, jump directly with centering
                if #options.items == 1 then
                  local item = options.items[1]
                  vim.lsp.util.jump_to_location(item, "utf-8")
                  vim.cmd("normal! zt7<C-y>")
                else
                  -- Otherwise show Telescope picker
                  require("telescope.builtin").lsp_definitions(options)
                end
              end,
              reuse_win = true,
            })
          end, "Goto Definition")

          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "gI", "<cmd>Telescope lsp_implementations<cr>", "Goto Implementation")
          map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
          map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
          map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
          map("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, "List Workspace Folders")
          map("n", "<leader>D", "<cmd>Telescope lsp_type_definitions<cr>", "Type Definition")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "gr", "<cmd>Telescope lsp_references<cr>", "References")
          
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map("n", "<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, "Toggle Inlay Hints")
          end
        end,
      })

      -- Capabilities
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities(),
        opts.capabilities or {}
      )

      -- Mason
      require("mason").setup()
      local ensure_installed = vim.tbl_keys(opts.servers or {})
      
      -- Ensure formatters are installed
      require("mason-tool-installer").setup({
        ensure_installed = {
          "stylua", -- Formatting
          "prettier", -- Formatting
          "isort",
          "black",
          "gofumpt", -- Better than gofmt
          "shfmt", -- Bash formatting
          "vue-language-server", -- Vue LSP
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
        handlers = {
          function(server_name)
            local server_opts = opts.servers[server_name] or {}
            server_opts.capabilities = capabilities
            -- Use vim.lsp.config/enable instead of lspconfig[name].setup
            vim.lsp.config(server_name, server_opts)
            vim.lsp.enable(server_name)
          end,
        },
      })

      -- Manual setup for Volar (Vue)
      vim.lsp.config("volar", {
        capabilities = capabilities,
      })
      vim.lsp.enable("volar")
    end,
  },

  -- CMP (Completion)
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        dependencies = {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
      },
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
      }
    end,
  },
}
