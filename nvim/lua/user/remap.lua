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
