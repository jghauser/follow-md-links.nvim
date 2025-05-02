# follow-md-links.nvim

This neovim plugin allows you to follow markdown links by pressing enter when the cursor is positioned on a link. It supports:

- absolute file paths (e.g. `[a file](/home/user/file.md)`)
- relative file paths (e.g. `[a file](../somefile.txt)`)
- file paths beginning with `~` (e.g. `[a file](~/folder/a_file)`).
- file paths with a line number (e.g. `[a file](/home/user/file.md:42)`), this will also place the cursor on the specified line similar to `gF` (see :h gF)
- reference links (e.g. `[a file][label]. [label]: ~/folder/a_file`)
- text-only reference links (e.g. `[example website]. [example website]: https://example.org`)
- web links (e.g. `[wikipedia](https://wikipedia.org)`)
- heading links (e.g. `[chapter 1](#-chapter-1)`)
- file path with heading link (e.g. `[file.md #chapter 1](file.md#-chapter-1)`)

Local files are opened in neovim and web links are opened with the default browser. Web links need to start with `https://` or `http://` to be identified properly.

This plugin is tested against the latest stable version of neovim. It might work with other versions, but this is not guaranteed.


## Installation

Packer:

```lua
use {
  'jghauser/follow-md-links.nvim'
}
```

lazy.nvim:
```lua
return {
   'jghauser/follow-md-links.nvim',
   dependencies = {
      'nvim-treesitter/nvim-treesitter',
   },
   ft = { 'markdown' },
   opts = true,
   cmd = { 'FollowMdLinks' },
   keys = {},
}
```
or

```lua
return {
   'jghauser/follow-md-links.nvim',
   dependencies = {
      'nvim-treesitter/nvim-treesitter',
   },
   config = function()
      require('follow-md-links').setup(),
   end,
   ft = { 'markdown' },
   cmd = { 'FollowMdLinks' },
   keys = {},
}
```

As this plugin uses [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) to identify links, you will need that plugin, and you will need to make sure you have the treesitter markdown and markdown_inline parsers installed. You can check whether that is the case by looking at the entries in `:checkhealth nvim-treesitter` (there should be a tick in the "H" column). If the markdown parsers are missing, install it with `TSInstall markdown markdown_inline` or by adding them to `ensure_installed` in your nvim-treesitter setup function.


## Configuration

### Default options
```lua
opts = {
   ft = { 'markdown' }, -- limit command to specific filetypes
   formatter = {
      heading_link = function(link)
         link = link:gsub("-", "[- ]*")
         link = link:gsub("_", "[_ ]*")
         return link
      end,
   },
},
```

### formatter

#### heading_link

##### Sample code 1 - heading_link

Sample `heading_link` formatter (Treat '-' and '_' as any symbol character)
```lua
heading_link = function(link)
   local symbols = '[' .. [[ ,.<>/?!;:(){}\[\]@#$%^&*+_="'\\|%%-]] .. ']'
   link = link:gsub('[-_]', symbols .. '*')
   link = link .. symbols .. '*$' -- it may have symbol at the end
   return link
end,
```

##### Sample code 2 - heading_link

- Treat 'and' as 'and' or '&'
- Treat 'at'  as 'at'  or '@'

```lua
heading_link = function(link)
   local symbols = '[' .. [[ ,.<>/?!;:(){}\[\]@#$%^&*+_="'\\|%%-]] .. ']'
   link = link:gsub('[-_]', symbols .. '*')
   link = link:gsub("and", "\\(&\\|and\\)") -- 'and' --> '&' or 'and'
   link = link:gsub("at", "\\(@\\|at\\)") -- 'at' --> '@' or 'at'
   link = link .. symbols .. '*$' -- it may have symbol at the end
   return link
end,

```

### keymaps

```lua
keys = {
   { '<cr>', '<cmd>FollowMdLinks<cr>', desc = 'Follow markdown link', ft = 'markdown' },
   { '<bs', ':edit #<cr>', desc = 'Back to the previous file', ft = 'markdown'},
},
```

## Usage

With your cursor on link and...

Command:
```vim
:FollowMdLinks
```
Lua:
```lua
require('follow-md-links').follow_link()
```



