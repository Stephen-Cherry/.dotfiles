----Options----
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.sidescrolloff = 15
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 15
vim.opt.colorcolumn = "88"
vim.opt.cursorline = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.smartcase = true
vim.opt.ignorecase = true
---------------
----Remaps----
local map = vim.keymap.set

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("n", "Q", "<nop>")

-- Disable Space (Used for leader key)
map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Set Codeium default keys
map('i', '<M-CR>', function() return vim.fn['codeium#Accept']() end, { expr = true })
map('i', '<M-]>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
map('i', '<M-[>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
map('i', '<M-C>', function() return vim.fn['codeium#Clear']() end, { expr = true })
map('i', '<M-BS>', function() return vim.fn['codeium#Complete']() end, { expr = true })

-- Move line up/down in visual mode
map("v", "<C-j>", ":m '>+1<CR>gv=gv")
map("v", "<C-k>", ":m '<-2<CR>gv=gv")

-- Move line up/down in normal mode
map("n", "<C-j>", ":m +1<CR>")
map("n", "<C-k>", ":m -2<CR>")
---------------
----Keymaps----
local function toggle_background()
  local current_background = vim.o.background
  local new_background

  if current_background == 'light' then
    vim.cmd 'set background=dark'
    new_background = 'dark'
  else
    vim.cmd 'set background=light'
    new_background = 'light'
  end

  local file = io.open(vim.fn.stdpath 'config' .. '/nvim_background.txt', 'w')
  if file then
    file:write(new_background)
    file:close()
  end
end

local function read_background_setting()
  local file = io.open(vim.fn.stdpath 'config' .. '/nvim_background.txt', 'r')
  if file then
    local background_setting = file:read '*all'
    file:close()

    if background_setting == 'light' then
      vim.cmd 'set background=light'
    else
      vim.cmd 'set background=dark'       -- Default to dark if empty or invalid
    end
  else
    vim.cmd 'set background=dark'     -- Default to dark if the file doesn't exist
  end
end

read_background_setting()

lvim.builtin.which_key.mappings['S'] = {
  name = "Stephen",
  ['u'] = { vim.cmd.UndotreeToggle, "Undo Tree" },
  ['r'] = { [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Replace" },
  ['x'] = { "<cmd>!chmod +x %<CR>", { silent = true }, "Make File Executable" },
  ['b'] = { toggle_background, 'Toggle Background' },
  ['p'] = {
    name = "Python",
    ['e'] = { '<cmd>:VenvSelect<cr>', "Environment" }
  },
  ['m'] = {
    name = "Make It",
    r = { "<cmd>CellularAutomaton make_it_rain<CR>", "Rain" }
  }
}
---------------
----Plugins----
lvim.plugins = {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
    opts = {
      name={"venv", ".venv"},
      auto_refresh = true,
      search_venv_managers = false,
    },
    event = "VeryLazy",
  },
  {
    'Exafunction/codeium.vim',
    event = 'BufEnter'
  },
  {
    'christoomey/vim-tmux-navigator'
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    opts = {}
  },
  {
    "tpope/vim-fugitive",
  },
  {
    "eandrju/cellular-automaton.nvim"
  },
  {
    "laytan/cloak.nvim",
    opts = {
      enabled = true,
      cloak_character = "🔒",
      patterns = {
        file_pattern = {
          ".env*",
        },
        cloak_pattern = "=.+",
      },
    }
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = {
      ensure_installed = {
        "csharp_ls",
        "gopls",
        'delve',
        'debugpy',
        "golines",
        "goimports",
        "golangci-lint",
        "pyright",
        "lua_ls",
        "tsserver",
        "html",
        "jsonls",
        "marksman",
        "selene",
        "markdownlint",
        "eslint_d",
        "pylint",
        "black",
      }
    }
  },
  {
    "leoluz/nvim-dap-go",
    opts = {},
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      local mason_path = "~/.local/share/nvim/mason"
      require("dap-python").setup(mason_path .. "/packages/debugpy/venv/bin/python")
    end
  },
}
---------------
----Null-ls----
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { name = "black" },
  {
    name = "prettier",
    args = { "--print-width", "100" },
    filetypes = { "typescript", "typescriptreact" },
  },
}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { name = "ruff" },
  {
    name = "shellcheck",
    args = { "--severity", "warning" },
  },
}

local code_actions = require "lvim.lsp.null-ls.code_actions"
code_actions.setup {
  {
    name = "proselint",
  },
}
---------------
