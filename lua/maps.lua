-- maps.lua

local map = vim.api.nvim_set_keymap

-- map the leader key
map('n', '<Space>', '', {})
vim.g.mapleader = ' '

-- map ';' to ':' for easy command execution
map('n', ';', ':', {noremap = true})

-- function to toggle diagnostics
vim.g.diagnostics_visible = true
function _G.toggle_diagnostics()
	if vim.g.diagnostics_visible then 
		vim.g.diagnostics_visible = false
		vim.diagnostic.disable()
	else
		vim.g.diagnostics_visible = true
		vim.diagnostic.enable()
	end
end
map('n', '<leader>tt', ':call v:lua.toggle_diagnostics()<CR>', {noremap = true, silent = true})
