-- custom.lua
-- Custom configuration
vim.opt.splitbelow = true
vim.opt.splitright = true

-- length of an actual \t character:
vim.o.tabstop = 3
-- length to use when editing text (eg. TAB and BS keys)
-- (0 for ‘tabstop’, -1 for ‘shiftwidth’):
vim.osofttabstop = -1
-- length to use when shifting text (eg. <<, >> and == commands)
-- (0 for ‘tabstop’):
vim.o.shiftwidth = 0
-- round indentation to multiples of 'shiftwidth' when shifting text
-- (so that it behaves like Ctrl-D / Ctrl-T):
vim.o.shiftround = true

-- if set, only insert spaces; otherwise insert \t and complete with spaces:
vim.o.expandtab = true

-- reproduce the indentation of the previous line:
vim.o.autoindent = true
-- keep indentation produced by 'autoindent' if leaving the line blank:
--vim.o.cpoptions += I
-- try to be smart (increase the indenting level after ‘{’,
-- decrease it after ‘}’, and so on):
vim.o.smartindent = true
-- a stricter alternative which works better for the C language:
vim.o.cindent = true
-- use language‐specific plugins for indenting (better):
--filetype plugin indent on

-- Display the invisible characters
vim.opt.list = true
vim.opt.listchars = {
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
