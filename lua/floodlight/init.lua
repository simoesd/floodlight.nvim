local M = {}

--- @class Colors
--- @field dim vim.api.keyset.highlight Highlight group for non-matched characters.
--- @field primary vim.api.keyset.highlight Highlight group for the first character in each jump tag.
--- @field secondary vim.api.keyset.highlight Highlight group for the second character in each jump tag.
--- @see See vim.api.nvim_set_hl()

--- @alias WordSplitCallback fun(line_text: string, start_col: integer): false|integer Receives a full line of text (`line_text`), and the position from which to start the matching (`start_col`). Returns the column of the next matched caracter, or `false` if no match exists. This method will be called repeatedly until `false` is returned, so ensure it always terminates.

--- @class FloodlightConfig
--- @field colors? Colors Highlight groups to be used
--- @field character_list? string List of characters to use as tags for each possible jump point
--- @field word_split_callback? WordSplitCallback|"simple"|"spider" Method that defines how jump points within a line. `spider` requires `chrisgrieser/nvim-spider` and should follow it's configured `w` behavior, while `base` attempts to closely simulate Neovim's built in "w" behavior.

--- @type FloodlightConfig
local config = {
    colors = {
        dim = { fg = "#5f7096" },
        primary = { fg = "#f79559" },
        secondary = { fg = "#80a6f0" },
    },
    character_list = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ[](){}<>",
    word_split_callback = "simple",
}

--- @param opts? FloodlightConfig
function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})

    vim.api.nvim_create_user_command("FloodlightJump", function()
        require("floodlight.floodlight").start_jump()
    end, {})
end

return M
