-- TABLE OF CONTENTS
-- 1. Plugins
-- 2. General Options
-- 3. Keymaps
-- 4. Autocommands
-- 5. Colorsheme
-- 6. Statusline
-- 7. LSP General Config
-- 8. LSP - Lua
-- 9. LSP - Go

-- 1. Plugins -----------------------------------------------------------------
vim.pack.add({
  'https://github.com/shaunsingh/nord.nvim',
  'https://github.com/neovim/nvim-lspconfig',
})

-- 2. General Options ---------------------------------------------------------
vim.opt.termguicolors = true            -- Enable term GUI colors
vim.opt.fileencoding = "utf-8"          -- Set file encoding to UTF-8
vim.opt.updatetime = 100                -- Set faster completion
vim.opt.mouse = "a"                     -- Enable mouse support
vim.opt.undofile = true                 -- Enable persistent undo file
vim.opt.swapfile = false                -- Disable swap file
vim.opt.showmode = false                -- Dont show since its already in statusline
vim.opt.iskeyword:append("-")           -- Treat words separated by - as one word
vim.opt.fillchars:append({ eob = " " }) -- Remove curly braces in line number
vim.o.showcmd = false                   -- Dont show commands in bottom right
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"     -- Enable copying to system clipboard
end)
vim.opt.confirm = true                  -- Raise dialog asking to save current file

-- Searching Behaviors
vim.opt.hlsearch = true   -- Highlight all matches in search
vim.opt.ignorecase = true -- Ignore case in search
vim.opt.smartcase = true  -- Match case if explicitly stated
vim.opt.path:append('**') -- Search down info subfolders

-- Splits
vim.opt.splitbelow = true -- Force horizontal splits below current window
vim.opt.splitright = true -- Force vertical splits right of current window

-- Indentation
vim.opt.tabstop = 2        -- Number of spaces inserted for tab character
vim.opt.shiftwidth = 2     -- Number of spaces inserted for each indentation level
vim.opt.softtabstop = 2    -- Number of spaces inserted for tab character
vim.opt.expandtab = true   -- Convert tabs to spaces
vim.opt.smartindent = true -- Enable smart indentation
vim.opt.breakindent = true -- Enable line breaking indentation

-- Lines
vim.opt.number = true
vim.opt.relativenumber = false -- Display line number
vim.opt.wrap = false           -- Display lines as single line
vim.opt.cursorline = true      -- Highlight current line

-- Appearance
vim.opt.scrolloff = 10     -- Number of lines to keep above/below cursor
vim.opt.sidescrolloff = 10 -- Number of columns to keep to the left/right of cursor

-- Code Folding
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "syntax"

-- Misc
vim.g.markdown_recommended_style = 0 -- Fix markdown indentation settings

-- 3. Autocommands -----------------------------------------------------------
local custom_group = vim.api.nvim_create_augroup('custom', { clear = true })

vim.cmd([[au BufEnter * set fo-=c fo-=r fo-=o]]) -- Disable new line comments

-- highlight yanked text for 200ms using the "Visual" highlight group
vim.cmd([[
  augroup highlight_yank
  autocmd!
  au TextYankPost * silent! lua vim.highlight.on_yank({higroup="Visual", timeout=300})
  augroup END
]])


-- Remove items from quickfix list.
-- `dd` to delete in Normal
-- `d` to delete Visual selection
local function delete_qf_items()
  local mode = vim.api.nvim_get_mode()['mode']

  local start_idx
  local count

  if mode == 'n' then
    -- Normal mode
    start_idx = vim.fn.line('.')
    count = vim.v.count > 0 and vim.v.count or 1
  else
    -- Visual mode
    local v_start_idx = vim.fn.line('v')
    local v_end_idx = vim.fn.line('.')

    start_idx = math.min(v_start_idx, v_end_idx)
    count = math.abs(v_end_idx - v_start_idx) + 1

    -- Go back to normal
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(
        '<esc>', -- what to escape
        true,    -- Vim leftovers
        false,   -- Also replace `<lt>`?
        true     -- Replace keycodes (like `<esc>`)?
      ),
      'x',       -- Mode flag
      false      -- Should be false, since we already `nvim_replace_termcodes()`
    )
  end

  local qflist = vim.fn.getqflist()

  for _ = 1, count, 1 do
    table.remove(qflist, start_idx)
  end

  vim.fn.setqflist(qflist, 'r')
  vim.fn.cursor(start_idx, 1)
end

-- quicklist commands
vim.api.nvim_create_autocmd('FileType', {
  group = custom_group,
  pattern = 'qf',
  callback = function()
    -- Do not show quickfix in buffer lists.
    vim.bo.buflisted = false

    -- Escape closes quickfix window.
    vim.keymap.set(
      'n',
      '<ESC>',
      '<CMD>cclose<CR>',
      { buffer = true, remap = false, silent = true }
    )

    -- `dd` deletes an item from the list.
    vim.keymap.set('n', 'dd', delete_qf_items, { buffer = true })
    vim.keymap.set('x', 'd', delete_qf_items, { buffer = true })
  end,
  desc = 'Quickfix tweaks',
})

-- 4. Keymaps -----------------------------------------------------------------
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap.set("n", ";p", '"0P', opts)       -- Paste last yanked

keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- Shift visual selected line down
keymap.set("v", "K", ":m '<-2<CR>gv=gv") -- Shift visual selected line up

keymap.set("n", "J", "mzJ`z")
keymap.set("n", "<C-d>", "<C-d>zz") -- Middle view when going down
keymap.set("n", "<C-u>", "<C-u>zz") -- Middle view when going up
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

keymap.set("n", "<leader>w", ":w<CR>", { desc = "[W]rite File" })   -- write file
keymap.set("n", "<leader>e", ":qa<CR>", { desc = "[E]xit Neovim" }) -- exit Neovim

-- Panes
keymap.set("n", "<c-h>", "<c-w>h", opts)
keymap.set("n", "<c-j>", "<c-w>j", opts)
keymap.set("n", "<c-k>", "<c-w>k", opts)
keymap.set("n", "<c-l>", "<c-w>l", opts)

-- Windows
keymap.set("n", "<leader>\\", ":vsplit<CR>", { desc = "which_key_ignore", silent = true })
keymap.set("n", "<leader>-", ":split<CR>", { desc = "which_key_ignore", silent = true })

-- Buffers
keymap.set("n", "<tab>", ":bnext<CR>", opts)
keymap.set("n", "<s-tab>", ":bprev<CR>", opts)
keymap.set("n", "<leader>bd", ":bdelete!<CR>", { desc = "[B]uffer [D]elete" })

-- Vertical split resize
keymap.set("n", "<C-Left>", ":vertical resize +3<CR>")
keymap.set("n", "<C-Right>", ":vertical resize -3<CR>")
keymap.set("n", "<C-Up>", ":resize +3<CR>")
keymap.set("n", "<C-Down>", ":resize -3<CR>")

-- Continuing indentation
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Highlight
keymap.set("n", "<esc>", "<cmd>noh<cr><esc>") -- Clear search highlight

-- Quickfixlist (Toggle)
keymap.set("n", "<leader>ql", function()
  local qf_win = vim.fn.getqflist({ winid = 0 }).winid
  if qf_win ~= 0 then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end, { desc = "[Q]uickfix List" })


keymap.set('n', ']d', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Next diagnostic' })

keymap.set('n', '[d', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Previous diagnostic' })

-- 5. Colorscheme -----------------------------------------------------------------
vim.g.nord_contrast = true
vim.g.nord_borders = false
vim.g.nord_disable_background = false
vim.g.nord_italic = false
vim.g.nord_uniform_diff_background = true
vim.g.nord_bold = true
vim.cmd.colorscheme("nord")

-- 6. Statusline -----------------------------------------------------------------
local modes = {
  ["n"] = "NORMAL",
  ["no"] = "NORMAL",
  ["v"] = "VISUAL",
  ["V"] = "VISUAL LINE",
  [""] = "VISUAL BLOCK",
  ["s"] = "SELECT",
  ["S"] = "SELECT LINE",
  [""] = "SELECT BLOCK",
  ["i"] = "INSERT",
  ["ic"] = "INSERT",
  ["R"] = "REPLACE",
  ["Rv"] = "VISUAL REPLACE",
  ["c"] = "COMMAND",
  ["cv"] = "VIM EX",
  ["ce"] = "EX",
  ["r"] = "PROMPT",
  ["rm"] = "MOAR",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  ["t"] = "TERMINAL",
}

local function mode()
  local current_mode = vim.api.nvim_get_mode().mode
  return string.format(" %s ", modes[current_mode]):upper()
end

local function update_mode_colors()
  local current_mode = vim.api.nvim_get_mode().mode
  local mode_color = "%#StatusLineAccent#"
  if current_mode == "n" then
    mode_color = "%#StatuslineAccent#"
  elseif current_mode == "i" or current_mode == "ic" then
    mode_color = "%#StatuslineInsertAccent#"
  elseif current_mode == "v" or current_mode == "V" or current_mode == "" then
    mode_color = "%#StatuslineVisualAccent#"
  elseif current_mode == "R" then
    mode_color = "%#StatuslineReplaceAccent#"
  elseif current_mode == "c" then
    mode_color = "%#StatuslineCmdLineAccent#"
  elseif current_mode == "t" then
    mode_color = "%#StatuslineTerminalAccent#"
  end
  return mode_color
end

local function file_path()
  local fpath = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")
  if fpath == "" or fpath == "." then
    return " "
  end

  return string.format(" %%<%s/", fpath)
end

local function file_name()
  local fname = vim.fn.expand "%:t"
  if fname == "" then
    return ""
  end
  return fname .. " "
end

local function line_info()
  -- Ensure we don't divide by zero
  local total_lines = vim.fn.line("$")
  if total_lines == 0 then return "" end

  local current_line = vim.fn.line(".")
  local column = vim.fn.col(".")

  -- Calculate scrollbar position
  -- We use math.min to ensure we don't exceed the array index
  local sbar_chars = { " ", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
  local i = math.floor((current_line - 1) / total_lines * #sbar_chars) + 1
  i = math.min(i, #sbar_chars)

  local sbar = sbar_chars[i]

  -- Ensure highlight groups are strings
  -- Assuming 'StatusLinePosition' and 'Scrollbar' are registered hl groups
  local hl_pos = "StatusLinePosition"
  local hl_sbar = "Scrollbar"

  return string.format(" %%#%s# %d:%d %%#%s#%s ", hl_pos, current_line, column, hl_sbar, sbar)
end


-- Define specific colors for your statusline LSP sections
vim.api.nvim_set_hl(0, 'StatusLspError', { fg = '#ff6666', bg = '#3d1c1c' })
vim.api.nvim_set_hl(0, 'StatusLspWarn', { fg = '#fabd2f', bg = '#3d381c' })
vim.api.nvim_set_hl(0, 'StatusLspInfo', { fg = '#83a598', bg = '#1c303d' })
vim.api.nvim_set_hl(0, 'StatusLspHint', { fg = '#8ec07c', bg = '#1c3d35' })

local function lsp_diagnostics()
  local count = {
    error = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }),
    warn  = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }),
    info  = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO }),
    hint  = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }),
  }

  local errors = count.error > 0 and ("%#StatusLspError#  " .. count.error .. " ") or ""
  local warnings = count.warn > 0 and ("%#StatusLspWarn#  " .. count.warn .. " ") or ""
  local info = count.info > 0 and ("%#StatusLspInfo#  " .. count.info .. " ") or ""
  local hints = count.hint > 0 and ("%#StatusLspHint# 󰌵 " .. count.hint .. " ") or ""

  return errors .. warnings .. info .. hints .. "%#StatusLine#"
end

local function file_type()
  return string.format(" %s ", vim.bo.filetype):upper()
end

local git_info = function()
  local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
  if branch ~= "" then
    return " " .. branch --  is the standard Git branch icon
  end
  return ""
end

local function percentage()
  local current_line = vim.fn.line(".")
  local total_lines = vim.fn.line("$")

  -- Calculate percentage
  if total_lines == 0 then return " 0%% " end
  local pct = math.floor((current_line / total_lines) * 100)

  return string.format("%%#StatusLineAccent# %d%%%%", pct)
end

Statusline = {}

Statusline.active = function()
  return table.concat {
    "%#Statusline#",
    update_mode_colors(),
    mode(),
    "%#Normal# ",
    git_info(),
    file_path(),
    file_name(),
    "%#Normal#",
    lsp_diagnostics(),
    "%=%#StatusLineExtra#",
    file_type(),
    percentage(),
    line_info(),
    -- lineinfo(),
  }
end

function Statusline.inactive()
  return " %F"
end

function Statusline.short()
  return "%#StatusLineNC#   NvimTree"
end

local statusline_group = vim.api.nvim_create_augroup('Statusline', { clear = true })

-- Helper to set statusline
local function set_status(val)
  vim.opt_local.statusline = val
end

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
  group = statusline_group,
  callback = function()
    if vim.bo.filetype == 'NvimTree' then
      set_status("%!v:lua.Statusline.short()")
    else
      set_status("%!v:lua.Statusline.active()")
    end
  end,
})

vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
  group = statusline_group,
  callback = function()
    set_status("%!v:lua.Statusline.inactive()")
  end,
})


-- 7. LSP General Config -----------------------------------------------------------------
local buffer_setup = function()
  local set_mapping = function(key, cmd, modes)
    modes = modes or { 'n' }
    for _, mode in pairs(modes) do
      vim.api.nvim_buf_set_keymap(0, mode, key, cmd, { noremap = true })
    end
  end

  set_mapping('gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
  set_mapping('<space>fc', '<cmd>lua vim.lsp.buf.format({ async = true })<cr>')

  -- Hover
  set_mapping('K', '<cmd>lua vim.lsp.buf.hover()<cr>')
  set_mapping('<space>k', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

  -- References
  set_mapping('grr', '<cmd>lua vim.lsp.buf.references()<cr>')
  set_mapping('gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

  -- Symbol Search
  set_mapping('grs', '<cmd>lua vim.lsp.buf.document_symbol()<cr>')
  set_mapping('grw', '<cmd>lua vim.lsp.buf.workspace_symbol()<cr>')
  set_mapping('grn', '<cmd>lua vim.lsp.buf.rename()<cr>')
end

vim.diagnostic.config({
  virtual_text = false,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "󰌵",
    },
  },

})

-- Format code on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*', -- Or specifically for Go: pattern = '*.go'
  callback = function(args)
    -- Get clients for this specific buffer
    local clients = vim.lsp.get_clients({ bufnr = args.buf })

    -- Iterate through clients and find one that supports formatting
    for _, client in ipairs(clients) do
      if client.supports_method(client, 'textDocument/formatting') then
        vim.lsp.buf.format({
          async = false,
          id = client.id,
        })
      end
    end
  end,
})

-- Import packages on save
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   group = vim.api.nvim_create_augroup('setGoFormatting', { clear = true }),
--   pattern = '*.go',
--   callback = function()
--     local params = vim.lsp.util.make_range_params(0, "utf-8")
--     params.context = { only = { "source.organizeImports" } }
--     local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 2000)
--     for _, res in pairs(result or {}) do
--       for _, r in pairs(res.result or {}) do
--         if r.edit then
--           vim.lsp.util.apply_workspace_edit(r.edit, "utf-16")
--           --else
--           --  vim.lsp.buf.execute_command(r.command)
--         end
--       end
--     end
--   end
-- })

-- 8. LSP - Lua -----------------------------------------------------------------
vim.lsp.config('lua_ls', {
  on_attach = buffer_setup,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
    },
  },
})

vim.lsp.enable('lua_ls')

-- 9. LSP - Go -----------------------------------------------------------------
vim.lsp.config('gopls', {
  on_attach = buffer_setup,
  settings = {
    gopls = {
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        unusedparams = true
      },
      staticcheck = true,
      semanticTokens = false,
      gofumpt = true, -- Formatter
      completeUnimported = true,
      usePlaceholders = true,
    }
  }
})

vim.lsp.enable('gopls')
