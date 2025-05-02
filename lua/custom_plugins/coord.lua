local base_colors = require("base_colors")
local spider_motion = require("spider.motion-logic")
local spider_config = require("spider.config").globalOpts

vim.api.nvim_set_hl(0, "CoordDim", { fg = base_colors.comment })
vim.api.nvim_set_hl(0, "CoordPrimary", { fg = base_colors.orange })
vim.api.nvim_set_hl(0, "CoordSecondary", { fg = base_colors.magenta })

local ns = vim.api.nvim_create_namespace("coord")
vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
local character_list = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local M = {}
M.jump_list = {}

local get_word_jump_list = function(lnum)
    local line_text = vim.fn.getline(lnum)
    M.jump_list[lnum] = {}
    local next_word = 0
    local i = 1
    local prev_mark = -1000
    while true do
        next_word = spider_motion.getNextPosition(line_text, next_word, "w", spider_config)
        if next_word == nil then
            break
        end

        -- If the marks are too close together we skip them, to avoid confusion when they overlap or are directly next to eachother.
        -- For example, the marks "aa" and "ab" could be drawn as "aab" and "aaab" without this check
        if next_word - prev_mark > 2 then
            local jump_char = character_list:sub(i, i)
            if i > #character_list then
                break
            end
            -- Extmark and cursor repositioning are 0 indexed, while character positions are 1 indexed
            M.jump_list[lnum][jump_char] = next_word - 1
            prev_mark = next_word
            i = i + 1
        end
    end
end

local set_extmarks_for_line = function(lnum, line_shortcut)
    for word_shortcut, col in pairs(M.jump_list[lnum]) do
        vim.api.nvim_buf_set_extmark(0, ns, lnum - 1, col, {
            hl_mode = "combine",
            virt_text = {
                {
                    line_shortcut,
                    "CoordPrimary",
                },
                {
                    word_shortcut,
                    "CoordSecondary",
                },
            },
            virt_text_pos = "overlay",
            strict = false,
            priority = 0,
        })
    end
end

local apply_dim = function()
    vim.hl.range(0, ns, "CoordDim", "w0", "w$", { priority = 500 })
end

local jump_col = function(lnum, typed)
    local jump_col = M.jump_list[lnum][typed]
    if jump_col ~= nil then
        vim.fn.cursor(lnum, jump_col + 1)
    end
    M.jump_list = {}
end

local jump_line = function(_, typed)
    local jump_lnum = character_list:find(typed, 0, true)
    apply_dim()
    if jump_lnum ~= nil then
        jump_lnum = vim.fn.line("w0") + jump_lnum - 1
        set_extmarks_for_line(jump_lnum, typed)
        vim.fn.setcursorcharpos(jump_lnum, 0)
        vim.cmd.redraw()
        local ok, char = pcall(vim.fn.getchar)
        if ok and type(char) == "number" then
            jump_col(jump_lnum, vim.fn.nr2char(char))
        end
    end
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

M.start_jump = function()
    local first_shown_lnum = vim.fn.line("w0")
    local last_shown_lnum = vim.fn.line("w$")
    M.jump_list = {}
    apply_dim()
    for lnum = first_shown_lnum, last_shown_lnum do
        local char_index = lnum - first_shown_lnum + 1
        if char_index > #character_list then
            break
        end

        local line_shortcut = character_list:sub(char_index, char_index)
        get_word_jump_list(lnum)
        set_extmarks_for_line(lnum, line_shortcut)
    end
    vim.cmd.redraw()
    local ok, char = pcall(vim.fn.getchar)
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    if ok and type(char) == "number" then
        jump_line("", vim.fn.nr2char(char))
    end
end

vim.api.nvim_create_user_command("CoordJump", function()
    M.start_jump()
end, {})

return M
