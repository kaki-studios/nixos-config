local map = vim.keymap.set
local opts = { noremap = true, silent = true }

local function split_commentstring()
  local cs = vim.bo.commentstring
  if not cs or cs == "" or not cs:find "%%s" then
    return nil, nil
  end
  local left, right = cs:match "^(.*)%%s(.*)$"
  if not left then
    return nil, nil
  end
  return vim.trim(left), vim.trim(right)
end

local function toggle_comment_range(line_start, line_end)
  local left, right = split_commentstring()
  if not left then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
  local escaped_left = vim.pesc(left)
  local escaped_right = right ~= "" and vim.pesc(right) or nil

  local all_commented = true
  for _, line in ipairs(lines) do
    if line:match "%S" then
      local ok_left = line:match("^%s*" .. escaped_left)
      local ok_right = (right == "") or line:match(escaped_right .. "%s*$")
      if not (ok_left and ok_right) then
        all_commented = false
        break
      end
    end
  end

  for i, line in ipairs(lines) do
    if line:match "%S" then
      if all_commented then
        line = line:gsub("^(%s*)" .. escaped_left .. "%s?", "%1", 1)
        if right ~= "" then
          line = line:gsub("%s?" .. escaped_right .. "%s*$", "", 1)
        end
      else
        local indent, rest = line:match "^(%s*)(.*)$"
        line = indent .. left .. " " .. rest
        if right ~= "" then
          line = line .. " " .. right
        end
      end
    end
    lines[i] = line
  end

  vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, false, lines)
end

map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", opts)

map("n", "<Esc>", "<cmd>noh<CR>", opts)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-l>", "<C-w>l", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-c>", "<cmd>%y+<CR>", opts)

map("n", "<leader>n", "<cmd>set nu!<CR>", opts)
map("n", "<leader>rn", "<cmd>set rnu!<CR>", opts)
map("n", "<leader>b", "<cmd>enew<CR>", opts)
map("n", "<leader>ch", "<cmd>WhichKey<CR>", opts)

map("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, silent = true })
map("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, silent = true })
map("n", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, silent = true })
map("n", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, silent = true })

map("v", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, silent = true })
map("v", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, silent = true })
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)
map("x", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, silent = true })
map("x", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, silent = true })
map("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', opts)

map("t", "<C-x>", "<C-\\><C-N>", opts)

map("n", "<tab>", "<cmd>bnext<CR>", opts)
map("n", "<S-tab>", "<cmd>bprevious<CR>", opts)
map("n", "<leader>x", "<cmd>bdelete<CR>", opts)

map("n", "<leader>/", function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  toggle_comment_range(line, line)
end, opts)
map("v", "<leader>/", function()
  local first = vim.fn.line "v"
  local last = vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  toggle_comment_range(first, last)
end, opts)

map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", opts)
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", opts)

map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts)
map("n", "<leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", opts)
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", opts)
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", opts)
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", opts)
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", opts)
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", opts)
map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", opts)
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", opts)
map("n", "<leader>ma", "<cmd>Telescope marks<CR>", opts)

map("n", "<leader>fm", function()
  vim.lsp.buf.format { async = true }
end, opts)

map("n", "gD", vim.lsp.buf.declaration, opts)
map("n", "gd", vim.lsp.buf.definition, opts)
map("n", "K", function()
  vim.lsp.buf.hover { border = "rounded" }
end, opts)
map("n", "gi", vim.lsp.buf.implementation, opts)
map("n", "<leader>ls", function()
  vim.lsp.buf.signature_help { border = "rounded" }
end, opts)
map("n", "<leader>D", vim.lsp.buf.type_definition, opts)
map("n", "<leader>ra", vim.lsp.buf.rename, opts)
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
map("n", "gr", vim.lsp.buf.references, opts)
map("n", "<leader>f", function()
  vim.diagnostic.open_float { border = "rounded" }
end, opts)
map("n", "[d", function()
  vim.diagnostic.goto_prev { float = { border = "rounded" } }
end, opts)
map("n", "]d", function()
  vim.diagnostic.goto_next { float = { border = "rounded" } }
end, opts)
map("n", "<leader>q", vim.diagnostic.setloclist, opts)
map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
map("n", "<leader>wl", function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, opts)

map("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", opts)
map("n", "<leader>dr", "<cmd>DapContinue<CR>", opts)

map("n", "<leader>se", vim.diagnostic.open_float)
