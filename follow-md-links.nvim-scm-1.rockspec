local MODREV, SPECREV = 'scm', '-1'
rockspec_format = '3.0'
package = 'follow-md-links.nvim'
version = MODREV .. SPECREV

description = {
  summary = 'Easily follow markdown links with this neovim plugin',
  detailed = [[
    This neovim plugin allows you to follow markdown links by pressing
    enter when the cursor is positioned on a link.
  ]],
  labels = { 'neovim', 'plugin', },
  homepage = 'https://github.com/jghauser/follow-md-links.nvim',
  license = 'GPL3',
}

dependencies = {
  "lua >= 5.1, < 5.4",
}

source = {
  url = 'git://github.com/jghauser/follow-md-links.nvim',
}
