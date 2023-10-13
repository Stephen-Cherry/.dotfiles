local wk = require('which-key')
local dap = require 'dap'
local dapui = require 'dapui'

local function close_with_confirmation()
    -- Check if the buffer has pending changes
    local current_buffer = vim.api.nvim_get_current_buf()
    local modified = vim.api.nvim_get_option_value('modified', { buf = current_buffer })

    if modified then
        local unsaved_changes = vim.fn['confirm']('Save changes before closing?', '&Yes\n&No\n&Cancel')
        if unsaved_changes == 1 then
            vim.cmd 'wq!'
        elseif unsaved_changes == 2 then
            vim.cmd 'q!'
        end
    else
        -- If there are no changes, simply close the file
        vim.cmd 'q!'
    end
end

local function close_buffer_with_confirmation()
    -- Check if the buffer has pending changes
    local current_buffer = vim.api.nvim_get_current_buf()
    local modified = vim.api.nvim_get_option_value('modified', { buf = current_buffer })

    if modified then
        local unsaved_changes = vim.fn['confirm']('Save changes before closing?', '&Yes\n&No\n&Cancel')
        if unsaved_changes == 1 then
            vim.cmd 'w | bd'
        elseif unsaved_changes == 2 then
            vim.cmd 'bd!'
        end
    else
        -- If there are no changes, simply close the file
        vim.cmd 'bd!'
    end
end
-- Function to toggle the background and update the configuration file
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

    -- Update the configuration file
    local file = io.open(vim.fn.stdpath 'config' .. '/nvim_background.txt', 'w')
    if file then
        file:write(new_background)
        file:close()
    end
end

-- Read the background setting from the configuration file
local function read_background_setting()
    local file = io.open(vim.fn.stdpath 'config' .. '/nvim_background.txt', 'r')
    if file then
        local background_setting = file:read '*all'
        file:close()

        -- Check if the content is valid and set the background accordingly
        if background_setting == 'light' then
            vim.cmd 'set background=light'
        else
            vim.cmd 'set background=dark' -- Default to dark if empty or invalid
        end
    else
        vim.cmd 'set background=dark' -- Default to dark if the file doesn't exist
    end
end

-- Initialize the background setting
read_background_setting()

wk.register({
    ['u'] = { vim.cmd.UndotreeToggle, "Undo Tree" },
    ['J'] = { "mzJ`z", "Combine Line Up" },
    ['r'] = { [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Replace" },
    ['x'] = { "<cmd>!chmod +x %<CR>", { silent = true }, "Make File Executable" },
    ['v'] = {
        name = 'View',
        p = { "<cmd>e ~/.config/nvim/lua/user/plugins.lua<CR>", "Plugins" }
    },
    ['m'] = {
        name = "Make It",
        r = { "<cmd>CellularAutomaton make_it_rain<CR>", "Rain" }
    },

    ['b'] = { toggle_background, 'Toggle Background' },
    ['f'] = { vim.lsp.buf.format, "Format" },
    ['s'] = {
        name = 'Search',
        ['?'] = { '<cmd>Telescope oldfiles<cr>', 'Recently Opened Files' },
        ['b'] = { '<cmd>Telescope buffers<cr>', 'Existing Buffers' },
        ['c'] = { '<cmd>Telescope current_buffer_fuzzy_find<cr>', 'Current Buffer' },
        ['g'] = { '<cmd>Telescope git_files<cr>', 'Git Files' },
        ['f'] = { '<cmd>Telescope find_files<cr>', 'Git Files' },
        ['h'] = { '<cmd>Telescope help_tags<cr>', 'Git Files' },
        ['w'] = { '<cmd>Telescope grep_string<cr>', 'Git Files' },
        ['l'] = { '<cmd>Telescope live_grep<cr>', 'Git Files' },
        ['d'] = { '<cmd>Telescope diagnostics<cr>', 'Git Files' },
        ['r'] = { '<cmd>Telescope resume<cr>', 'Git Files' },
    },
    ['d'] = {
        name = 'Diagnostics',
        ['p'] = { vim.diagnostic.goto_prev, 'Previous Message' },
        ['n'] = { vim.diagnostic.goto_next, 'Next Message' },
        ['f'] = { vim.diagnostic.open_float, 'Floating Message' },
        ['l'] = { vim.diagnostic.setloclist, 'Open List' },
        ['t'] = { '<cmd>TroubleToggle quickfix<cr>', 'Trouble' },
    },
    ['D'] = {
        name = 'Debug',
        ['c'] = { dap.continue, 'Continue' },
        ['i'] = { dap.step_into, 'Step Into' },
        ['o'] = { dap.step_over, 'Step Over' },
        ['u'] = { dap.step_out, 'Step Out' },
        ['b'] = { dap.toggle_breakpoint, 'Toggle Breakpoint' },
        ['B'] = {
            function()
                dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
            end,
            'Set Breakpoint',
        },
        ['l'] = { dapui.toggle, 'Last Results' },
    },
    ['l'] = {
        name = 'Lsp',
        ['a'] = { vim.lsp.buf.code_action, 'Code Action' },
        ['r'] = { vim.lsp.buf.rename, 'Rename' },
        ['g'] = {
            name = 'Go To',
            ['d'] = { vim.lsp.buf.type_definition, 'Definition' },
            ['D'] = { vim.lsp.buf.declaration, 'Declaration' },
            ['r'] = { '<cmd>Telescope lsp_references<cr>', 'References' },
            ['a'] = { '<cmd>Telescope lsp_implementations<cr>', 'Implementation' },
        },
        ['s'] = {
            name = 'Symbols',
            ['d'] = { '<cmd>Telescope lsp_document_symbols<cr>', 'Implementation' },
            ['w'] = { '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', 'Implementation' },
        },
        ['h'] = { vim.lsp.buf.hover, 'Hover Documentation' },
        ['S'] = { vim.lsp.buf.signature_help, 'Signature Documentation' },
    },
    ['e'] = { '<cmd>Ex<cr>', 'Explorer' },
    ['q'] = { close_with_confirmation, 'Quit' },
    ['w'] = { '<cmd>w<cr>', 'Save' },
    ['c'] = { close_buffer_with_confirmation, 'Close Buffer' },
}, { prefix = "<leader>", mode = 'n' })

wk.register({
    J = { ":m '>+1<CR>gv=gv", "Move Line Up" },
    K = { ":m '<-2<CR>gv=gv", "Move Line Down" },
    p = { '[["_dP]]', "Paste No Overwrite" },
}, { prefix = "<leader>", mode = 'v' })
