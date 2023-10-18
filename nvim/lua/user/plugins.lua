return {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
    },
    {
        'Exafunction/codeium.vim',
        event = 'BufEnter'
    },
    {
        'mfussenegger/nvim-lint',
        config = function()
            local lint = require('lint')
            local selene = lint.linters.selene
            selene.args = {
                "--config",
                vim.fn.expand("~/.config/nvim/selene.toml"),
                "--display-style",
                "Json",
                "-"
            }

            lint.linters_by_ft = {
                markdown = { "markdownlint", },
                python = { "pylint", },
                javascript = { "eslint_d", },
                typescript = { "eslint_d", },
                lua = { "selene", },
                go = { "golangcilint", },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    lint.try_lint()
                end,
            })
        end
    },
    {
        'christoomey/vim-tmux-navigator'
    },
    {
        'nvim-lualine/lualine.nvim',
        opts = {
        }
    },
    { 'nvim-tree/nvim-web-devicons',  opt = true },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {}
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
            dapui.setup()
        end,
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
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme 'catppuccin'
        end,
    },
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")

            configs.setup({
                ensure_installed = { "c_sharp", "go", "lua", "vim", "vimdoc", "javascript", "python", "html" },
                sync_install = false,
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },
    { "nvim-treesitter/playground" },
    { "theprimeagen/refactoring.nvim" },
    { "mbbill/undotree" },
    {
        "tpope/vim-fugitive",
    },
    { "nvim-treesitter/nvim-treesitter-context" },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        lazy = true,
        config = false,
        init = function()
            -- Disable automatic setup, we are doing it manually
            vim.g.lsp_zero_extend_cmp = 0
            vim.g.lsp_zero_extend_lspconfig = 0
        end,
    },
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = true,
    },

    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            { 'L3MON4D3/LuaSnip' },
        },
        config = function()
            -- Here is where you configure the autocompletion settings.
            local lsp_zero = require('lsp-zero')
            lsp_zero.extend_cmp()

            -- And you can configure cmp even more, if you want to.
            local cmp = require('cmp')
            local cmp_action = lsp_zero.cmp_action()

            cmp.setup({
                formatting = lsp_zero.cmp_format(),
                mapping = cmp.mapping.preset.insert({
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function()
                        if cmp.visible() then
                            cmp.select_prev_item()
                        end
                    end, { "i", "s" }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
                    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
                })
            })
        end
    },

    -- LSP
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'williamboman/mason-lspconfig.nvim' },
        },
        config = function()
            -- This is where all the LSP shenanigans will live
            local lsp_zero = require('lsp-zero')
            lsp_zero.extend_lspconfig()

            lsp_zero.on_attach(function(_, bufnr)
                -- see :help lsp-zero-keybindings
                -- to learn the available actions
                lsp_zero.default_keymaps({ buffer = bufnr })
                lsp_zero.buffer_autoformat()
            end)

            require('mason-lspconfig').setup({
                ensure_installed = {},
                handlers = {
                    lsp_zero.default_setup,
                    lua_ls = function()
                        -- (Optional) Configure lua language server for neovim
                        local lua_opts = lsp_zero.nvim_lua_ls()
                        require('lspconfig').lua_ls.setup(lua_opts)
                    end,
                }
            })
        end
    },
    { "eandrju/cellular-automaton.nvim" },
    {
        "laytan/cloak.nvim",
        opts = {
            enabled = true,
            cloak_character = "*",
            -- The applied highlight group (colors) on the cloaking, see `:h highlight`.
            highlight_group = "Comment",
            patterns = {
                {
                    -- Match any file starting with ".env".
                    -- This can be a table to match multiple file patterns.
                    file_pattern = {
                        ".env*",
                        "wrangler.toml",
                        ".dev.vars",
                    },
                    -- Match an equals sign and any character after it.
                    -- This can also be a table of patterns to cloak,
                    -- example: cloak_pattern = { ":.+", "-.+" } for yaml files.
                    cloak_pattern = "=.+"
                },
            },
        }
    },
    {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        opts = {
            ensure_installed = {
                "black",
                "csharp_ls",
                "gopls",
                'delve',
                'debugpy',
                "golines",
                "goimports",
                "golangci-lint",
                "pylsp",
                "lua_ls",
                "tsserver",
                "html",
                "jsonls",
                "marksman",
                "selene",
                "pylint",
                "markdownlint",
                "eslint_d",
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
            local mason_path = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/")
            require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python")
        end
    },
}
