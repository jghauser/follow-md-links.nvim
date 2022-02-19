# follow-md-links.nvim

This neovim plugin allows you to follow local markdown links by pressing enter when the cursor is positioned on a link. It uses [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) to identify links. This is beta stage software and written by someone who's mostly just discovering how to write lua.

This plugin requires neovim v0.5.

## Installation

Packer:

```lua
use {
  'jghauser/follow-md-links.nvim',
  config = function()
    require('follow-md-links')
  end
}
```

You also need the [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) plugin, and you need to make sure you have treesitter markdown parser installed. If your nvim-treesitter config enables all maintained parsers, the markdown parser should be installed by default. You can check by looking at the markdown entry in `:checkhealth nvim-treesitter` (there should be a tick in the "H" column).

## Configuration

By default the plugin maps `<cr>` in normal mode to open links in markdown files. You might also want to add the following keymap to easily go back to the previous file with backspace:

```lua
vim.api.nvim_set_keymap('', '<bs>', ':edit #<cr>', {noremap = true, silent = true})
```

## TODO

- Follow links other than local links and open webpages in browser of choice
- Documentation
- Code legibility and comments
- Support filenames and paths with blanks
