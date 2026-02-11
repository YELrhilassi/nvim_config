local ml = require("mason-lspconfig")
local available = ml.get_available_servers()
if vim.tbl_contains(available, "volar") then
  print("volar is valid")
else
  print("volar is INVALID")
end

if vim.tbl_contains(available, "vue_ls") then
  print("vue_ls is valid")
end

-- Check for anything with "vue"
for _, name in ipairs(available) do
  if name:match("vue") then
    print("Found vue server: " .. name)
  end
end
