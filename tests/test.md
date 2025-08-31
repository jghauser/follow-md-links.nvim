- relative: [test](tests/link_target)
- relative: [test](.//link_target)
- absolute: [test](/home/julian/Documents/coding/neovim_plugins/follow-md-links.nvim/tests/link_target)
- absolute with ~: [test](~/Documents/coding/neovim_plugins/follow-md-links.nvim/tests/link_target)
- absolute with ~: [test](~/Documents/coding/neovim_plugins/follow-md-links.nvim/tests/link_target)
- anchor link: [test](~/Documents/coding/neovim_plugins/follow-md-links.nvim/tests/link_target#title)
- reference: [test][1]
  - [1]: ~/Documents/coding/neovim_plugins/follow-md-links.nvim/tests/link_target
- reference: [test][link]
  - [link]: http://wikipedia.org "test"
- text only reference: [link]
  - [link]: http://wikipedia.org "test"
- <https://www.wikipedia.org> -- TODO: doesn't yet work
- this is a footnote[^1] -- TODO: doesn't yet work
- with space: [test](<../tests/link target>)

[^1]: My footnote.

- http: [wikipedia](http://wikipedia.org)
- https: [wikipedia](https://wikipedia.org)

# a title

Can we [link to](#a-title).
