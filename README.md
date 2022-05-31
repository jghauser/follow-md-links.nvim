# follow-md-links.nvim

This neovim plugin allows you to follow markdown links by pressing enter when the cursor is positioned on a link. It supports:

- absolute file paths (e.g. `[a file](/home/user/file.md)`)
- relative file paths (e.g. `[a file](../somefile.txt)`)
- file paths beginning with `~` (e.g. `[a file](~/folder/a_file)`).
- reference links (e.g. `[a file][label]. [label]: ~/folder/a_file`)
- web links (e.g. `[wikipedia](https://wikipedia.org)`)

Local files are opened in neovim and web links are opened with the default browser. Web links need to start with `https://` or `http://` to be identified properly.

This plugin is tested against the latest stable version of neovim. It might work with other versions, but this is not guaranteed.

## Installation

Packer:

```lua
use {
  'jghauser/follow-md-links.nvim'
}
```

As this plugin uses [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) to identify links, you will need that plugin, and you will need to make sure you have the treesitter markdown parser installed. You can check whether that is the case by looking at the markdown entry in `:checkhealth nvim-treesitter` (there should be a tick in the "H" column). If the markdown parser is missing, install it with `TSInstall markdown` or by adding it to `ensure_installed` in your nvim-treesitter setup function.

## Configuration

The plugin maps `<cr>` in normal mode to open links in markdown files. You might also want to add the following keymap to easily go back to the previous file with backspace:

```lua
vim.keymap.set('n', '<bs>', ':edit #<cr>', { silent = true })
```
