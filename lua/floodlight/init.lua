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
local default_config = {
    colors = {
        dim = { fg = "#5f7096" },
        primary = { fg = "#f79559" },
        secondary = { fg = "#80a6f0" },
    },
    character_list = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ[](){}<>",
    word_split_callback = "simple",
}

local function simple_next(line_text, start_col)
    -- Ensures we don't get the same position multiple times
    start_col = start_col + 1
    -- The pattern we use never matches the first character, so we explicitly include it
    if start_col == 1 and vim.fn.match(line_text.sub(1, 1), "\\s") >= 0 then
        return start_col
    end
    local next_pos = vim.fn.matchstrpos(line_text, "\\%" .. start_col .. "v.\\{-}\\<.")[3]
    if next_pos == -1 or next_pos == start_col or next_pos >= vim.fn.strcharlen(line_text) then
        return false
    else
        return next_pos
    end
end

local function resolve_word_split_callback(config)
    if type(config) == "function" then
        return config
    else
        if type(config) == "string" and config == "spider" then
            if package.loaded["spider"] then
                local spider_motion = require("spider.motion-logic")
                local spider_config = require("spider.config").globalOpts
                local spider_next = function(line_text, start_col)
                    return spider_motion.getNextPosition(line_text, start_col, "w", spider_config)
                end
                return spider_next
            else
                vim.notify(
                    "Floodlight was setup to use `nvim-spider` integration, but spider is not loaded. Defaulting to the `simple` setting.",
                    vim.log.levels.WARN
                )
            end
        end
    end
    return simple_next
end

--- @param opts? FloodlightConfig
function M.setup(opts)
    local config = vim.tbl_deep_extend("force", default_config, opts or {})

    vim.api.nvim_set_hl(0, "FloodlightDim", config.colors.dim)
    vim.api.nvim_set_hl(0, "FloodlightPrimary", config.colors.primary)
    vim.api.nvim_set_hl(0, "FloodlightSecondary", config.colors.secondary)

    local floodlight = require("floodlight.floodlight")
    floodlight.character_list = config.character_list
    floodlight.word_split_callback = resolve_word_split_callback(config.word_split_callback)

    vim.g.floodlight_did_setup = true
end

vim.api.nvim_create_user_command("FloodlightJump", function()
    if not vim.g.floodlight_did_setup then
        M.setup({})
    end
    require("floodlight.floodlight").start_jump()
end, {})

return M
