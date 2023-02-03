-- custom.lua
-- Custom configuration
vim.opt.splitbelow = true
vim.opt.splitright = true

local source = '/home/fbaltor/.config/nvim/init.lua'
vim.keymap.set('n', '<leader>ev', '<cmd>vsp ' .. source .. '<cr>', {noremap = true, silent = true, desc = '[E]dit neo[V]im config file'})
vim.keymap.set('n', '<leader>sv', '<cmd>luafile ' .. source .. '<cr>', {noremap = true, silent = true, desc = '[S]ource neo[V]im config file'})
