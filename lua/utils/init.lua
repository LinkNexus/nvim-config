require("utils.theme")
require("utils.rex").setup()

function GET_CUSTOM_PLUGIN_PATH(plugin_name)
    return vim.fs.joinpath(vim.fn.stdpath("config"), "custom_plugins", plugin_name)
end
