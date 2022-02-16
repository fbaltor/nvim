-- maps.lua

local map = vim.api.nvim_set_keymap

-- map the leader key
map('n', '<Space>', '', {})
vim.g.mapleader = ' '

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

