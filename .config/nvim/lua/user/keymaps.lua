-- set leader key to space
vim.g.mapleader = " "

local git_cmd = require("user.git.cmd")
local which_key_status, which_key = pcall(require, "which-key")

if not which_key_status then
  return
end

which_key.setup({})

which_key.register({
  ["<c-\\>"] = { "<cmd>ToggleTerm<cr>", "Toggle terminal" },
  ["<leader>"] = {
    name = "+leader",
    R = { "<cmd>source $MYVIMRC<cr>", "Reload config" },
    w = { ":%s/\\<<C-r><C-w>\\>//g<Left><Left>", "Replace word under cursor" },
    s = {
      name = "+split",
      v = { "<C-w>v", "Split window vertically" },
      h = { "<C-w>s", "Split window horizontally" },
      e = { "<C-w>=", "Make split windows equal width & height" },
      x = { ":close<CR>", "Close current split window" },
      m = { "<cmd>MaximizerToggle<cr>", "Maximize current split window" },
    },
    t = {
      name = "+tab",
      o = { "<cmd>tabnew<cr>", "Open new tab" },
      x = { "<cmd>tabclose<cr>", "Close current tab" },
      n = { "<cmd>tabn<cr>", "Go to next tab" },
      p = { "<cmd>tabp<cr>", "Go to previous tab" },
    },
    g = {
      r = { git_cmd.open_file_on_remote, "Open file on remote" },
    },
  },
})