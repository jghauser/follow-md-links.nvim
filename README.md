# follow-md-links.nvim

This neovim plugin allows you to follow internal markdown links. It's written in lua and uses [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) to identify links. This is alpha stage software and written by someone who's mostly just discovering how to write lua.

This plugin requires neovim v0.5.

# Installation

Packer:

```
use {
  'jghauser/follow-md-links.nvim',
  config = function()
    require('follow-md-links')
  end
}
```

You also need the [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) plugin, and you need to enable the markdown parser (which can trigger crashes in certain situations). To install the markdown parser you need to add this to your nvim-treesitter setup:

```
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.markdown = {
    install_info = {
        url = "https://github.com/ikatyang/tree-sitter-markdown",
        files = {"src/parser.c", "src/scanner.cc"}
    },
    filetype = "markdown",
}
```

# Configuration

You might also want to add the following keymap to easily go back to the previous file with backspace:

```
vim.api.nvim_set_keymap('', '<bs>', ':edit #<cr>', {noremap = true, silent = true})
```

# TODO

- Follow links other than local links and open webpages in browser of choice
- Documentation
- Code legibility and comments
