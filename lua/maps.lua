-- maps.lua

local map = vim.api.nvim_set_keymap

-- map the leader key
map('n', '<Space>', '', {})
vim.g.mapleader = ' '

-- map ';' to ':' for easy command execution
map('n', ';', ':', {noremap = true})
