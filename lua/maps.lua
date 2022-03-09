-- maps.lua

local map = vim.api.nvim_set_keymap

-- map the leader key
map('n', '<Space>', '', {})
vim.g.mapleader = ' '

map('n', '<Leader>ww', [[<Cmd>w<CR>]], {noremap = true, silent = true} )
map('n', '<Leader>qq', [[<Esc><Cmd>q<CR>]], {noremap = true, silent = true} )


-- source
local source = '/home/fbaltor/.config/nvim/init.lua'
map('n', '<Leader>sv', [[<Cmd>luafile ]] ..source ..  [[<CR>]], {noremap = true, silent = true} )
map('n', '<Leader>ev', [[<Cmd>vsp ]] ..source ..  [[<CR>]], {noremap = true, silent = true} )

-- function to toggle diagnostics
vim.g.diagnostics_visible = true
function _G.toggle_diagnostics()
	if vim.g.diagnostics_visible then
		vim.g.diagnostics_visible = false
		vim.diagnostic.hide()
	else
		vim.g.diagnostics_visible = true
		vim.diagnostic.show()
	end
end
map('n', '<leader>tt', ':call v:lua.toggle_diagnostics()<CR>', {noremap = true, silent = true})

-- telescope
map('n', '<Leader>ff', [[<Cmd>lua require('telescope.builtin').find_files()<CR>]], {noremap = true, silent = true} )
map('n', '<Leader>fg', [[<Cmd>lua require('telescope.builtin').live_grep()<CR>]], {noremap = true, silent = true} )
map('n', '<Leader>fb', [[<Cmd>lua require('telescope.builtin').buffers()<CR>]], {noremap = true, silent = true} )
map('n', '<Leader>fh', [[<Cmd>lua require('telescope.builtin').help_tags()<CR>]], {noremap = true, silent = true} )
map('n', '<Leader>fh', [[<Cmd>lua require('telescope.builtin').help_tags()<CR>]], {noremap = true, silent = true} )
map('n', '<Leader>fl', [[<Cmd>vsp <CR><bar><Cmd> lua require('telescope.builtin').find_files() <CR>]], {noremap = true, silent = true} )
