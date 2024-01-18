-- custom.lua
-- Custom configuration
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.shiftwidth = 2
vim.opt.expandtab = true


-- Display the invisible characters
vim.opt.list = true
vim.opt.listchars = {
  space = '-',
  tab = '>>·',
  extends = '⟩',
  precedes = '⟨',
  trail = '·',
}
vim.cmd [[set invlist]]

vim.keymap.set('n', '<leader>ls', '<cmd>set invlist<cr>', {desc = 'Set inv[L]i[S]t'})

local source = '/home/fbaltor/.config/nvim/init.lua'
vim.keymap.set('n', '<leader>ev', '<cmd>vsp ' .. source .. '<cr>', {noremap = true, silent = true, desc = '[E]dit neo[V]im config file'})
vim.keymap.set('n', '<leader>sv', '<cmd>luafile ' .. source .. '<cr>', {noremap = true, silent = true, desc = '[S]ource neo[V]im config file'})

-- Deno 
vim.g.markdown_fenced_languages = {
	"ts=typescript"
}

vim.opt.cursorcolumn = true
vim.opt.cursorline = true
