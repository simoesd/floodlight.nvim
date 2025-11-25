# floodlight.nvim

Jump to an arbitrary word, anywhere on your screen.

[Video]


Once you initiate a jump, every line on the screen will be dimmed, and a two letter tag appears at the start of each word.
All words in each line will share the first character of a tag.
Pressing the first character in a tag will jump to the relevant line, hiding all the tags for other lines. Then, pressing the second character in a tag moves you to the relevant word.
The goal is to keep motions predictable and visible as soon as a jump is started.

## Features
 - Full screen navigation with a single shortcut, whether the destination is before or after the cursor;
 - Predictable 2 key motions. The first visible line on the screen will always start with the same key, and so will the first word of each line;
 - Configurable word detection, tag characters and highlight options;
 - Built in integration with [chrisgrieser/nvim-spider](https://github.com/chrisgrieser/nvim-spider), for better camel case, pascal case and special character navigation;

## Configuration
Currently, Floodlight has three configuration options:
 - `colors`: Which highlight groups to use for non-match (`dim`), start of match (`primary`), and end of match characters (`secondary`);
 - `character_list`: What characters to use when building tags and motion shortcuts. The characters are used in order (first character in this string will be used for the first line on screen, and first word of each line etc.). If you notice lines or words without jump tags, you should add more characters to this string.
 - word_split_callback: Method that determines where on each line tags are placed. By default, a method simulating Neovim's default `w` keybind, as well as one utilizing `nvim-spider` is included

### Configuration types
```lua
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
```


### Default config
```lua
local default_config = {
    colors = {
        dim = { fg = "#5f7096" },
        primary = { fg = "#f79559" },
        secondary = { fg = "#80a6f0" },
    },
    character_list = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ[](){}<>",
    word_split_callback = "simple",
}
```

## Similar plugins
 - [flash.nvim](https://github.com/folke/flash.nvim)
 - [leap.nvim](https://github.com/ggandor/leap.nvim)
 - [vim-sneak](https://github.com/justinmk/vim-sneak)
