return {
    "rachartier/tiny-inline-diagnostic.nvim",
    priority = 1000, -- needs to be loaded in first
    config = function()
        require('tiny-inline-diagnostic').setup()
    end
}
