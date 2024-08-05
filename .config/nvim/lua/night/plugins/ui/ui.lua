return {
    { --* Nice looking icons
		"echasnovski/mini.icons",
		event = "VeryLazy",
		config = function()
			require("mini.icons").setup()
			MiniIcons.mock_nvim_web_devicons() -- nvim_devicons compatibilty layer
		end,
	},
}
