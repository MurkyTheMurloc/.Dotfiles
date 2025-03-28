return {
    "luckasRanarison/tailwind-tools.nvim",

    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope.nvim", -- optional
        "neovim/nvim-lspconfig",         -- optional
        "saghen/blink.cmp",
    },
    opts = {

        server = {
            override = false,
        }
    } -- your configuration
}
