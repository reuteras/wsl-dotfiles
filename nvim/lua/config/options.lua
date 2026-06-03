-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = ","
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true

local opt = vim.opt
opt.autoindent = true -- Copy indentation from the previous line
opt.smartindent = true -- Enable smarter automatic indentation
opt.expandtab = true -- Use spaces instead of actual tabs
opt.tabstop = 4 -- A Tab character is rendered as 4 spaces wide
opt.shiftwidth = 4 -- Auto-indent commands (e.g., >>) use 4 spaces
opt.softtabstop = 4 -- Tab/Backtab keys use 4 spaces when inserting

opt.mouse = "a" -- Enable mouse support

-- ==============================================================================
-- BEHAVIOR AND SYSTEM INTEGRATION
-- ==============================================================================
opt.backspace = "indent,eol,start" -- Ensures backspace works as expected
opt.clipboard = "unnamedplus" -- Integrate with system clipboard for yank/put (requires external tool)
opt.swapfile = false -- Disable swap files to prevent clutter
opt.undofile = true -- Enable persistent undo history
