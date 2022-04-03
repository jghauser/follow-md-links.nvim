--
-- FOLLOW MD LINKS
--

local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

-- follow md links
nvim_buf_set_keymap(0, 'n', '<cr>', ':lua require("follow-md-links").follow_link()<cr>', {noremap = true, silent = true})
