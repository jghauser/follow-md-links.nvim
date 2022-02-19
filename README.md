# follow-md-links.nvim

This neovim plugin allows you to follow markdown links by pressing enter when the cursor is positioned on a link. It supports:

- absolute file paths (e.g. `[a file](/home/user/file.md)`)
- relative file paths (e.g. `[a file](../somefile.txt)`)
- file paths beginning with `~` (e.g. `[a file](~/folder/a_file)`).
- web links (e.g. `[wikipedia](https://wikipedia.org)`)

Local files are opened in neovim and web links are opened with the default browser (using `xdg-open`). Web links need to start with `https://` or `http://` to be identified properly.

The plugin uses [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) to identify links. This is beta stage software and written by someone who's mostly just discovering how to write lua. The plugin has only been tested under Linux.

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

You also need the [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) plugin, and you need to make sure you have the treesitter markdown parser installed. If your nvim-treesitter config enables all maintained parsers, the markdown parser should be installed by default. You can check by looking at the markdown entry in `:checkhealth nvim-treesitter` (there should be a tick in the "H" column).

## Configuration

By default the plugin maps `<cr>` in normal mode to open links in markdown files. You might also want to add the following keymap to easily go back to the previous file with backspace:

```lua
vim.api.nvim_set_keymap('', '<bs>', ':edit #<cr>', {noremap = true, silent = true})
```

## TODO

- Documentation
- Code legibility and comments
- Support filenames and paths with blanks?
