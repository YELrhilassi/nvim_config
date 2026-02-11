local M = {}

function M.check()
  local modified_buffers = {}
  
  -- Find all modified buffers
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buf, "modified") and vim.api.nvim_buf_get_option(buf, "buflisted") then
      local name = vim.api.nvim_buf_get_name(buf)
      if name == "" then name = "[No Name] (Buffer " .. buf .. ")" end
      table.insert(modified_buffers, {
        buf = buf,
        name = name,
        path = vim.api.nvim_buf_get_name(buf) -- Keep full path for diff logic
      })
    end
  end

  -- If no changes, quit immediately
  if #modified_buffers == 0 then
    vim.cmd("qa")
    return
  end

  -- If changes exist, show the interactive picker
  M.show_picker(modified_buffers)
end

function M.show_picker(items)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  pickers.new({}, {
    prompt_title = "Unsaved Changes - <C-s> Save All & Quit | <C-d> Discard All",
    finder = finders.new_table({
      results = items,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name,
          path = entry.path, -- Used by previewer
          bufnr = entry.buf, -- Used by previewer
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      define_preview = function(self, entry, status)
        -- Custom diff logic: Buffer vs File on Disk
        local pbuf = self.state.bufnr
        local bufnr = entry.bufnr
        
        -- Get content from buffer (unsaved state)
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local buffer_content = table.concat(lines, "\n")

        -- Get content from disk (saved state)
        local file_content = ""
        local path = entry.path
        if path and path ~= "" and vim.fn.filereadable(path) == 1 then
          local f = io.open(path, "r")
          if f then
            file_content = f:read("*all")
            f:close()
          end
        else
          file_content = "" -- New file
        end

        -- Calculate diff
        local diff = vim.diff(file_content, buffer_content, {
          result_type = "indices",
          algorithm = "patience",
          ctxlen = 3,
        })

        -- If no diff (shouldn't happen if modified), just show content
        if not diff then
          vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, lines)
          return
        end

        -- We need to render the diff. 
        -- Simplest way is using 'diff' command output style for visuals
        local cmd_diff = vim.fn.systemlist("diff -u " .. (path ~= "" and path or "/dev/null") .. " -", lines)
        
        -- If system diff fails or is empty, fallback to just showing lines
        if #cmd_diff == 0 then
           vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, lines)
        else
           vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, cmd_diff)
           vim.api.nvim_buf_set_option(pbuf, "filetype", "diff")
        end
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      
      -- Save All and Quit
      map("i", "<C-s>", function()
        for _, item in ipairs(items) do
          vim.api.nvim_buf_call(item.buf, function()
            vim.cmd("write")
          end)
        end
        actions.close(prompt_bufnr)
        vim.cmd("qa")
      end)

      -- Discard All and Quit
      map("i", "<C-d>", function()
        actions.close(prompt_bufnr)
        vim.cmd("qa!")
      end)

      return true
    end,
  }):find()
end

return M
