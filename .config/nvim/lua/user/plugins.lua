local fzf_make_cmd = "make"
-- Check if we have vim.uv otherwise use vim.loop
local uv = vim.uv or vim.loop

-- Fzf native build command for Apple Silicon
if uv.os_uname().machine == "arm64" then
  fzf_make_cmd = " arch -arm64 make"
end

return require("lazy").setup({
  defaults = {
    lazy = true,
  },
  -- Theme
  {
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
    name = "catppuccin",
    opts = {
      integrations = {
        illuminate = true,
        indent_blankline = {
          enabled = true,
          colored_indent_levels = false,
        },
        markdown = true,
      },
      flavour = "mocha",
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- GitHub CoPilot
  { "github/copilot.vim" },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.1",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = fzf_make_cmd }, -- Fzf native
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
  },

  -- Telescope orthogonal deps
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
    opts = function()
      return require("user.treesitter")
    end,
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
      local which_key_status, which_key = pcall(require, "which-key")
      if not which_key_status then
        return
      end
      which_key.register({
        [";"] = { ts_repeat_move.repeat_last_move_next, "move next" },
        [","] = { ts_repeat_move.repeat_last_move_previous, "move previous" },
        ["f"] = { ts_repeat_move.builtin_f, "move forward" },
        ["F"] = { ts_repeat_move.builtin_F, "move backward" },
        ["t"] = { ts_repeat_move.builtin_t, "move to" },
        ["T"] = { ts_repeat_move.builtin_T, "move to before" },
      }, { mode = { "n", "o", "x" } })
    end,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
      },
    },
  },

  -- Lualine
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", opt = true },
    opts = function()
      local function show_macro_recording()
        local recording_register = vim.fn.reg_recording()
        if recording_register == "" then
          return ""
        else
          return "Recording @" .. recording_register
        end
      end

      return {
        sections = {
          lualine_a = {
            "mode",
            { "macro-recording", fmt = show_macro_recording },
          },
          lualine_z = {
            "location",
            {
              "searchcount",
              maxcount = 999,
              timeout = 500,
            },
          },
        },
        options = {
          theme = "catppuccin",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        },
        extensions = { "lazy" },
      }
    end,
    config = function(_, opts)
      local lualine = require("lualine")
      lualine.setup(opts)

      local refresh_statusline = function()
        lualine.refresh({
          place = { "statusline" },
        })
      end

      vim.api.nvim_create_autocmd("RecordingEnter", {
        callback = refresh_statusline,
      })
      vim.api.nvim_create_autocmd("RecordingLeave", {
        callback = refresh_statusline,
      })
    end,
  },

  -- Tmux navigator
  "christoomey/vim-tmux-navigator",

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    tag = "nightly",
    lazy = true,
  },

  -- Maximizes and restores current window
  { "szw/vim-maximizer", event = "VeryLazy" },

  -- Add, delete, change surroundings
  { "tpope/vim-surround", event = { "BufReadPost", "BufNewFile" } },

  -- Commenting with gc
  {
    "numToStr/Comment.nvim",
    event = "BufRead",
    dependencies = {
      -- context aware commentstring for TypeScript
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      local opts = {
        pre_hook = function(ctx)
          -- Only for TypeScript React
          if vim.bo.filetype == "typescriptreact" then
            local U = require("Comment.utils")

            -- Determine whether to use linewise or blockwise commentstring
            local type = ctx.ctype == U.ctype.linewise and "__default" or "__multiline"

            -- Determine the location where to calculate commentstring from
            local location = nil
            if ctx.ctype == U.ctype.blockwise then
              location = require("ts_context_commentstring.utils").get_cursor_location()
            elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
              location = require("ts_context_commentstring.utils").get_visual_start_location()
            end

            return require("ts_context_commentstring.internal").calculate_commentstring({
              key = type,
              location = location,
            })
          end
        end,
      }
      require("Comment").setup(opts)
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp", -- completion plugin
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer", -- source for text in buffer
      "hrsh7th/cmp-path", -- source for file system paths
      "saadparwaiz1/cmp_luasnip", -- for autocompletion
      "onsails/lspkind.nvim", -- vs-code like icons for autocompletion
      {
        "L3MON4D3/LuaSnip", -- snippet engine
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            config = function()
              -- load vs-code like snippets from plugins (e.g. friendly-snippets)
              require("luasnip.loaders.from_vscode").lazy_load()
            end,
          }, -- useful snippets
        },
      },
    },
    opts = function()
      local completion = require("user.completion")
      return completion
    end,
  },

  -- Better text-objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter-textobjects" },
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      -- register all text objects with which-key

      local which_key_status, which_key = pcall(require, "which-key")
      if not which_key_status then
        return
      end

      ---@type table<string, string|table>
      local i = {
        [" "] = "Whitespace",
        ['"'] = 'Balanced "',
        ["'"] = "Balanced '",
        ["`"] = "Balanced `",
        ["("] = "Balanced (",
        [")"] = "Balanced ) including white-space",
        [">"] = "Balanced > including white-space",
        ["<lt>"] = "Balanced <",
        ["]"] = "Balanced ] including white-space",
        ["["] = "Balanced [",
        ["}"] = "Balanced } including white-space",
        ["{"] = "Balanced {",
        ["?"] = "User Prompt",
        _ = "Underscore",
        a = "Argument",
        b = "Balanced ), ], }",
        c = "Class",
        f = "Function",
        o = "Block, conditional, loop",
        q = "Quote `, \", '",
        t = "Tag",
      }
      local a = vim.deepcopy(i)
      for k, v in pairs(a) do
        ---@diagnostic disable-next-line: param-type-mismatch
        a[k] = v:gsub(" including.*", "")
      end

      local ic = vim.deepcopy(i)
      local ac = vim.deepcopy(a)
      for key, name in pairs({ n = "Next", l = "Last" }) do
        i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
        a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
      end
      which_key.register({
        mode = { "o", "x" },
        i = i,
        a = a,
      })
    end,
  },

  -- Managing & installing lsp servers, linters & formatters
  {
    "williamboman/mason.nvim", -- in charge of managing lsp servers, linters & formatters
    event = "VeryLazy",
    opts = {},
  },

  -- Configuring lsp servers
  {
    "neovim/nvim-lspconfig", -- easily configure language servers
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim", -- bridges gap b/w mason & lspconfig
      "hrsh7th/cmp-nvim-lsp", -- for autocompletion
      "jose-elias-alvarez/typescript.nvim", -- additional functionality for typescript server (e.g. rename file & update imports)
    },
    config = require("user.lsp.lspconfig"),
  },
  {
    "nvimdev/lspsaga.nvim", -- enhanced lsp uis
    event = "LspAttach",
    branch = "main",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      { "nvim-treesitter/nvim-treesitter" },
    },
    opts = {
      -- keybinds for navigation in lspsaga window
      move_in_saga = { prev = "<C-k>", next = "<C-j>" },
      -- use enter to open file with finder
      finder_action_keys = {
        open = "<CR>",
      },
      -- use enter to open file with definition preview
      definition_action_keys = {
        edit = "<CR>",
      },
    },
  },

  -- Formatting & linting
  {
    "jose-elias-alvarez/null-ls.nvim", -- configure formatters & linters
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "jayp0521/mason-null-ls.nvim", -- bridges gap b/w mason & null-ls
    },
    config = function()
      require("user.lsp.null-ls")
    end,
  },

  -- Git blame
  { "f-person/git-blame.nvim", event = "BufRead" },

  -- Highlight TODOs
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup({})
    end,
  },

  -- Show indent lines
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPre",
    opts = {
      use_treesitter = true,
      -- show_current_context = true,
      buftype_exclude = { "terminal", "nofile" },
      filetype_exclude = {
        "help",
        "packer",
        "NvimTree",
      },
    },
  },

  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = { delay = 200, modes_denylist = { "i" } },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },

  -- Which key
  "folke/which-key.nvim",

  -- Zen Mode
  {
    "folke/zen-mode.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("zen-mode").setup({
        window = {
          width = 150,
        },
        plugins = {
          tmux = { enabled = true },
          alacritty = { enabled = true, font = "16" },
          wezterm = { enabled = true, font = "16" },
        },
      })
    end,
  },

  -- Better diagnostics list and others
  {
    "folke/trouble.nvim",
    enable = false,
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "gf", "<cmd>TroubleToggle lsp_references<cr>", desc = "LSP references" },
      { "<leader>xt", "<cmd>TroubleToggle<cr>", desc = "Trouble" },
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
      { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
      { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").previous({ skip_groups = true, jump = true })
          else
            vim.cmd.cprev()
          end
        end,
        desc = "Previous quickfix item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            vim.cmd.cnext()
          end
        end,
        desc = "Next quickfix item",
      },
    },
  },

  -- Floating terminal
  {
    "akinsho/toggleterm.nvim",
    tag = "v2.6.0",
    event = "VeryLazy",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        start_in_insert = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
      })
    end,
  },

  -- Undo tree
  {
    "mbbill/undotree",
    config = function()
      local which_key_status, which_key = pcall(require, "which-key")
      if not which_key_status then
        return
      end
      which_key.register({
        ["<leader>"] = {
          u = { "<cmd>UndotreeToggle<cr>", "Toggle undotree" },
        },
      })
    end,
  },
})
