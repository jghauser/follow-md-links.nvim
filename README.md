# follow-md-links.nvim

This neovim plugin allows you to follow markdown links by pressing enter when the cursor is positioned on a link. It supports:

- absolute file paths (e.g. `[a file](/home/user/file.md)`)
- relative file paths (e.g. `[a file](../somefile.txt)`)
- file paths beginning with `~` (e.g. `[a file](~/folder/a_file)`).
- file paths with a line number (e.g. `[a file](/home/user/file.md:42)`), this will also place the cursor on the specified line similar to `gF` (see :h gF)
- reference links (e.g. `[a file][label]. [label]: ~/folder/a_file`)
- text-only reference links (e.g. `[example website]. [example website]: https://example.org`)
- web links (e.g. `[wikipedia](https://wikipedia.org)`)
- heading links (e.g. `[chapter 1](#-chapter-1)`
- man page links (e.g. `[printf library](man://printf(3))`)
- uri links (e.g. `<https://example.org>`)

Local files are opened in neovim and web links are opened with the default browser. Web links need to start with `https://` or `http://` to be identified properly.

This plugin is tested against the latest stable version of neovim. It might work with other versions, but this is not guaranteed.

## Installation

Packer:

```lua
use {
  'jghauser/follow-md-links.nvim'
}
```

Lazy.nvim:

```
{
  'jghauser/follow-md-links.nvim'
}
```

## Configuration

The plugin maps `<cr>` in normal mode to open links in markdown files. You might also want to add the following keymap to easily go back to the previous file with backspace:

```lua
vim.keymap.set('n', '<bs>', ':edit #<cr>', { silent = true })
```
