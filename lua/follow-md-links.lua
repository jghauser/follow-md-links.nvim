--
-- FOLLOW MD LINKS
--

local fn = vim.fn
local cmd = vim.cmd
local loop = vim.loop
local ts_utils = require('nvim-treesitter.ts_utils')
local query = require('vim.treesitter.query')

local M = {}

local os_name = loop.os_uname().sysname
local is_windows = os_name == 'Windows'
local is_macos = os_name == 'Darwin'
local is_linux = os_name == 'Linux'

local function get_link_destination()
  local node_at_cursor = ts_utils.get_node_at_cursor()
  local parent_node = node_at_cursor:parent()
  if not (node_at_cursor and parent_node) then
    return
  elseif node_at_cursor:type() == 'link_destination' then
    return vim.split(query.get_node_text(node_at_cursor, 0), '\n')[1]
  elseif node_at_cursor:type() == 'link_text' then
    return vim.split(query.get_node_text(ts_utils.get_next_node(node_at_cursor), 0), '\n')[1]
  elseif node_at_cursor:type() == 'inline_link' then
    local child_nodes = ts_utils.get_named_children(node_at_cursor)
    for _, v in pairs(child_nodes) do
	    if v:type() == 'link_destination' then
        return vim.split(query.get_node_text(v, 0), '\n')[1]
      end
    end
  else
    return
  end
end

local function resolve_link(link)
  local link_type
  if link:sub(1,1) == [[/]] then
    link_type = 'local'
    return link, link_type
  elseif link:sub(1,1) == [[~]] then
    link_type = 'local'
    return os.getenv("HOME") .. [[/]] .. link:sub(2), link_type
  elseif link:sub(1,8) == [[https://]] or link:sub(1,7) == [[http://]] then
    link_type = 'web'
    return link, link_type
  else
    link_type = 'local'
    return fn.expand('%:p:h') .. [[/]] .. link, link_type
  end
end

local function follow_local_link(link)
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

function M.follow_link()
  local link_destination = get_link_destination()

  if link_destination then
    local resolved_link, link_type = resolve_link(link_destination)
    if link_type == 'local' then
      follow_local_link(resolved_link)
    elseif link_type == 'web' then
      if is_linux then
        vim.fn.system('xdg-open ' .. vim.fn.shellescape(resolved_link))
      elseif is_macos then
        vim.fn.system('open ' .. vim.fn.shellescape(resolved_link))
      elseif is_windows then
        vim.fn.system('cmd.exe /c start "" ' .. vim.fn.shellescape(resolved_link))
      end
    end
  end
end

return M
