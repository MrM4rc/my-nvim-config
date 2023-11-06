local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

local function map(mode, lhs, rhs, opts)
  local options = { noremap=true, silent=true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
	-- LSP Support
	{
	    'VonHeikemen/lsp-zero.nvim',
	    branch = 'v3.x',
	    lazy = true,
	    config = false,
	},
	{
	'neovim/nvim-lspconfig',
		dependencies = {
			{'hrsh7th/cmp-nvim-lsp'},
		}
	},
	-- Autocompletion
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			{'L3MON4D3/LuaSnip'}
		},
	},
	{'jremmen/vim-ripgrep'},
	{'nvim-tree/nvim-tree.lua'},
	{'nvim-tree/nvim-web-devicons'},
	{'oxfist/night-owl.nvim'},
	{'NLKNguyen/papercolor-theme'},
	{'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},
	{'dense-analysis/ale'},
	{'vim-airline/vim-airline'},
	{'polirritmico/monokai-nightasty.nvim'},
	{'tpope/vim-fugitive'},
  {'mrtazz/molokai.vim'},
  {
	  'uloco/bluloco.nvim',
	  lazy = false,
	  priority = 1000,
	  dependencies = { 'rktjmp/lush.nvim' },
  },
  -- {'Yggdroot/indentLine'},
  {'prisma/vim-prisma'},
  { 'Issafalcon/lsp-overloads.nvim'},
  {'nvim-treesitter/nvim-treesitter-refactor'},
  {'sainnhe/sonokai'},
  {'akinsho/git-conflict.nvim', version = "*", config = true},
  {
    'numToStr/Comment.nvim',
    opts = {
        -- add any options here
    },
    lazy = false,
  },
  {'m-demare/hlargs.nvim'},
  -- {'wfxr/minimap.vim'},
  {
    'maxmx03/dracula.nvim',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function ()
    local dracula = require 'dracula'

        dracula.setup()

    end
  },
  {'simrat39/symbols-outline.nvim'},
  {
    'gorbit99/codewindow.nvim',
    config = function()
      local codewindow = require('codewindow')
      codewindow.setup({
        auto_enable = true,
      })
      codewindow.apply_default_keybinds()
    end,
  },

})

vim.g.sonokai_style = 'andromeda'
vim.g.sonokai_better_performance = 1

vim.opt.termguicolors = true
vim.cmd.colorscheme('dracula')


local TAB_WIDTH = 2
vim.opt.tabstop = TAB_WIDTH
vim.opt.shiftwidth = TAB_WIDTH
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.bo.softtabstop = TAB_WIDTH
vim.opt.redrawtime = 10000000

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
  local opts = {buffer = bufnr}

  vim.keymap.set({'n', 'x'}, '<C-i>', ':ALEFix<CR>', opts)
  vim.keymap.set('n', '<C-RightMouse>', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
   if client.server_capabilities.signatureHelpProvider then
    -- Setup for better overload docs
    require('lsp-overloads').setup(client, {
      -- UI options are mostly the same as those passed to vim.lsp.util.open_floating_preview
        ui = {
          border = "single",           -- The border to use for the signature popup window. Accepts same border values as |nvim_open_win()|.
          height = nil,               -- Height of the signature popup window (nil allows dynamic sizing based on content of the help)
          width = nil,                -- Width of the signature popup window (nil allows dynamic sizing based on content of the help)
          wrap = true,                -- Wrap long lines
          wrap_at = nil,              -- Character to wrap at for computing height when wrap enabled
          max_width = nil,            -- Maximum signature popup width
          max_height = nil,           -- Maximum signature popup height
          -- Events that will close the signature popup window: use {"CursorMoved", "CursorMovedI", "InsertCharPre"} to hide the window when typing
          close_events = { "CursorMoved", "BufHidden", "InsertLeave" },
          focusable = true,           -- Make the popup float focusable
          focus = false,              -- If focusable is also true, and this is set to true, navigating through overloads will focus into the popup window (probably not what you want)
          offset_x = 0,               -- Horizontal offset of the floating window relative to the cursor position
          offset_y = 0,                -- Vertical offset of the floating window relative to the cursor position
          floating_window_above_cur_line = false, -- Attempt to float the popup above the cursor position 
                                                 -- (note, if the height of the float would be greater than the space left above the cursor, it will default 
                                                 -- to placing the float below the cursor. The max_height option allows for finer tuning of this)
          silent = true               -- Prevents noisy notifications (make false to help debug why signature isn't working)
        },
        keymaps = {
          next_signature = "<C-j>",
          previous_signature = "<C-k>",
          next_parameter = "<C-l>",
          previous_parameter = "<C-h>",
          close_signature = "<A-s>"
        },
        display_automatically = true -- Uses trigger characters to automatically display the signature overloads when typing a method signature
      })
  end
end)

lsp_zero.set_server_config({
  on_init = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local lspconfig = require('lspconfig')

lspconfig.cssls.setup {
  capabilities = capabilities,
}
lspconfig.tsserver.setup({})
lspconfig.rust_analyzer.setup({})
lspconfig.prismals.setup({})
lspconfig.sqlls.setup({})

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

-- settuping autocomplete
local cmp = require('cmp')
cmp.setup({
	completion = { autocomplete = false },
	mapping = cmp.mapping.preset.insert({
		['<C-Space>'] = cmp.mapping.complete(),
		['<CR>'] = cmp.mapping.confirm({select = false}), 
	}),
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	}
})


-- Terminal mappings
map('n', '<C-t>', ':terminal<CR>', {noremap=true})

-- Ctrl Shift F - File finder
map('n', '<C-f>', ':Rg ', {noremap=true})

-- Close current buffer
map('n', '<C-e>', ':bd<CR>')

map('', '<S-Tab>', ':bnext<CR>')

map('i', '<A-s>', '<cmd>LspOverloadsSignature<CR>', { noremap = true, silent = true })
map('n', '<A-s>', ':LspOverloadsSignature<CR>', { noremap = true, silent = true })

-- nvim-tree
--
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- OR setup with some options
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
    git_ignored = false
  },
})

-- use ctrl d to open/close tree
map('n', '<C-d>', ':NvimTreeToggle<CR>')

require('nvim-web-devicons').setup {
 -- your personnal icons can go here (to override)
 -- you can specify color or cterm_color instead of specifying both of them
 -- DevIcon will be appended to `name`
 override = {
  zsh = {
    icon = "",
    color = "#428850",
    cterm_color = "65",
    name = "Zsh"
  }
 };
 -- globally enable different highlight colors per icon (default to true)
 -- if set to false all icons will have the default icon's color
 color_icons = true;
 -- globally enable default icons (default to false)
 -- will get overriden by `get_icons` option
 default = true;
 -- globally enable "strict" selection of icons - icon will be looked up in
 -- different tables, first by filename, and if not found by extension; this
 -- prevents cases when file doesn't have any extension but still gets some icon
 -- because its name happened to match some extension (default to false)
 strict = true;
 -- same as `override` but specifically for overrides by filename
 -- takes effect when `strict` is true
 override_by_filename = {
  [".gitignore"] = {
    icon = "",
    color = "#f1502f",
    name = "Gitignore"
  }
 };
 -- same as `override` but specifically for overrides by extension
 -- takes effect when `strict` is true
 override_by_extension = {
  ["log"] = {
    icon = "",
    color = "#81e043",
    name = "Log"
  }
 };
}

require('bufferline').setup{}

require('nvim-treesitter.configs').setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "typescript", "javascript", "json" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or "all")
  ignore_install = {},

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  refactor = {
    highlight_definitions = {
      enable = true,
      -- Set to false if you have an `updatetime` of ~100.
      clear_on_cursor_move = true,
    },
  },

}

require('hlargs').setup()

-- ALE configs
vim.g.ale_fixers = {
  javascript = {'prettier', 'eslint'},
  typescript = {'prettier', 'eslint'},
  typescriptreact = {'prettier', 'eslint'}
}

-- airline configs

-- comment plugin
require('Comment').setup()

-- minimap setup
-- vim.g.minimap_width = 20
-- vim.g.minimap_auto_start_win_enter = 1
-- vim.cmd([[
--   autocmd VimEnter * :Minimap
-- ]])

-- LSP Symbols
require("symbols-outline").setup({
  auto_close = true,
  show_guides = true,
})

map('n', '<C-q>', ':SymbolsOutline<CR>', { noremap = true })


