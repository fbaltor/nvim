local ts = require 'nvim-treesitter.configs'

ts.setup {
	-- One of "all", "maintained" (parsers with maintainers), or a list of languages
	ensure_installed = "all",

	highlight = {
		enable = true
	},

	indent = {
		enable = true
	},
}
