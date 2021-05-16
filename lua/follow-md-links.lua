--
-- FOLLOW MD LINKS
--

local fn = vim.fn
local cmd = vim.cmd
local loop = vim.loop
local ts_utils = require 'nvim-treesitter.ts_utils'

local M = {}

local function get_link()
  local node_at_cursor = ts_utils.get_node_at_cursor()
  local parent_node = node_at_cursor:parent()
  if not node_at_cursor or not parent_node then
    return
  elseif parent_node:type() == 'link_destination' then
    return ts_utils.get_node_text(node_at_cursor, 0)[1]
  elseif parent_node:type() == 'link_text' then
    return ts_utils.get_node_text(ts_utils.get_next_node(parent_node), 0)[1]
  elseif node_at_cursor:type() == 'link' then
    local child_nodes = ts_utils.get_named_children(node_at_cursor)
    for k, v in pairs(child_nodes) do
	    if v:type() == 'link_destination' then
        return ts_utils.get_node_text(v)[1]
      end
    end
  else
    return
  end
end

local function resolve_link(link)
  if string.sub(link,1,1) == [[/]] then
    return link
  else
    return fn.expand('%:p:h') .. [[/]] .. link
  end
end

function M.follow_link()
  local link = get_link()

  if link then
    link = resolve_link(link)
    local fd = loop.fs_open(link, "r", 438)
    if fd then
      local stat = loop.fs_fstat(fd)
      if not stat or not stat.type == 'file' or not loop.fs_access(link, 'R') then
        loop.fs_close(fd)
      else
        loop.fs_close(fd)
        cmd(string.format('%s %s', 'e', fn.fnameescape(link)))
      end
    end
  end
end

return M
