--
-- FOLLOW MD LINKS
--

local fn = vim.fn
local cmd = vim.cmd
local treesitter = require("vim.treesitter")

local sysname = vim.uv.os_uname().sysname

local is_windows = sysname == "Windows_NT"
local is_macos = sysname == "Darwin"
local is_linux = sysname == "Linux"

local block_parser
local block_tree
local block_root
local inline_parser
local inline_tree
local inline_root

local function get_reference_link_destination(link_label)
  local parsed_query = vim.treesitter.query.parse("markdown", [[
  (link_reference_definition
    (link_label) @label (#eq? @label "]] .. link_label .. [[")
    (link_destination) @link_destination)
  ]])
  -- Problem with handling whitespace in filenames elegently is with this iter_matches
  for _, captures, _ in parsed_query:iter_matches(block_root, 0) do
    -- Prior to Neovim 0.11, `match` in `Query:iter_matches()` referred to a single match
    -- https://github.com/neovim/neovim/commit/bd5008de07d29a6457ddc7fe13f9f85c9c4619d2
    local match
    if vim.fn.has('nvim-0.10') == 0 then
      match = captures[2]
    else
      assert(#captures[2] == 1)
      match = captures[2][1]
    end
    local node_text = treesitter.get_node_text(match, 0)
    -- Kludgy method right now is to require that filenames with spaces are wrapped in <>,
    -- which are stripped out after the matching is complete
    return string.gsub(node_text, "[<>]", "")
  end
end

local function get_inline_node_at_cursor(row, col)
  -- Find the block node at the cursor
  local block_node = block_root:named_descendant_for_range(row, col, row, col)
  if not block_node then return nil end

  -- Find the 'inline' child node
  local inline_node = nil
  if block_node:type() == "inline" then
    inline_node = block_node
  else
    for i = 0, block_node:named_child_count() - 1 do
      local child = block_node:named_child(i)
      if child:type() == "inline" then
        inline_node = child
        break
      end
    end
  end
  if not inline_node then return nil end

  -- Find the node at the cursor in the inline tree
  local inline_cursor_node = inline_root:named_descendant_for_range(row, col, row, col)
  return inline_cursor_node
end

local function get_link_destination()
  block_parser = vim.treesitter.get_parser(0, "markdown")
  inline_parser = vim.treesitter.get_parser(0, "markdown_inline")
  if not block_parser or not inline_parser then
    return
  end
  block_tree = block_parser:parse()[1]
  block_root = block_tree:root()
  inline_tree = inline_parser:parse()[1]
  inline_root = inline_tree:root()

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]

  local node_at_cursor = get_inline_node_at_cursor(row, col)
  if not node_at_cursor then
    return
  end

  local parent_node = node_at_cursor and node_at_cursor:parent()
  if not (node_at_cursor and parent_node) then
    return
  elseif node_at_cursor:type() == "link_destination" then
    return vim.split(treesitter.get_node_text(node_at_cursor, bufnr), "\n")[1]
  elseif node_at_cursor:type() == "shortcut_link" then
    local link_text = vim.split(treesitter.get_node_text(node_at_cursor, bufnr), "\n")[1]
    return get_reference_link_destination(link_text)
  elseif node_at_cursor:type() == "link_text" then
    if node_at_cursor:parent():type() == "shortcut_link" then
      local link_text = vim.split(treesitter.get_node_text(node_at_cursor:parent(), bufnr), "\n")[1]
      return get_reference_link_destination(link_text)
    end
    local parent = node_at_cursor:parent()
    local next_node = nil
    if parent then
      local named_count = parent:named_child_count()
      for i = 0, named_count - 2 do
        if parent:named_child(i) == node_at_cursor then
          next_node = parent:named_child(i + 1)
          break
        end
      end
    end
    if next_node and next_node:type() == "link_destination" then
      return vim.split(treesitter.get_node_text(next_node, bufnr), "\n")[1]
    elseif next_node and next_node:type() == "link_label" then
      local link_label = vim.split(treesitter.get_node_text(next_node, bufnr), "\n")[1]
      return get_reference_link_destination(link_label)
    end
  elseif node_at_cursor:type() == "link_reference_definition" or node_at_cursor:type() == "inline_link" then
    local child_nodes = {}
    for i = 0, node_at_cursor:named_child_count() - 1 do
      table.insert(child_nodes, node_at_cursor:named_child(i))
    end
    for _, node in pairs(child_nodes) do
      if node:type() == "link_destination" then
        return vim.split(treesitter.get_node_text(node, bufnr), "\n")[1]
      end
    end
  elseif node_at_cursor:type() == "full_reference_link" then
    local child_nodes = {}
    for i = 0, node_at_cursor:named_child_count() - 1 do
      table.insert(child_nodes, node_at_cursor:named_child(i))
    end
    for _, node in pairs(child_nodes) do
      if node:type() == "link_label" then
        local link_label = vim.split(treesitter.get_node_text(node, bufnr), "\n")[1]
        return get_reference_link_destination(link_label)
      end
    end
  elseif node_at_cursor:type() == "link_label" then
    local link_label = vim.split(treesitter.get_node_text(node_at_cursor, bufnr), "\n")[1]
    return get_reference_link_destination(link_label)
	elseif node_at_cursor:type() == "uri_autolink" then
		local link_label = vim.split(treesitter.get_node_text(node_at_cursor, 0), "\n")[1]
		return string.gsub(link_label, "^<(.-)>$", "%1")
  else
    return
  end
end

local function resolve_link(link)
  local link_type
  if link:sub(1, 1) == [[/]] then
    link_type = "local"
    return link, link_type
  elseif link:sub(1, 1) == [[#]] then
    link_type = "heading"
    return link:sub(2), link_type
  elseif link:sub(1, 1) == [[~]] then
    link_type = "local"
    return os.getenv("HOME") .. [[/]] .. link:sub(2), link_type
  elseif link:sub(1, 8) == [[https://]] or link:sub(1, 7) == [[http://]] then
    link_type = "web"
    return link, link_type
  elseif link:sub(1, 6) == [[man://]] then
    link_type = "man"
    return link, link_type
  else
    link_type = "local"
    return fn.expand("%:p:h") .. [[/]] .. link, link_type
  end
end

local function follow_local_link(link)
  local modified_link = nil
  local path_and_line_number = vim.split(link, ":")
  local path = path_and_line_number[1]

  -- attempt to parse line number, will be nil if index 2 does not exist
  local line_number = path_and_line_number[2]

  -- check if it is a directory, and create if true
  if path:sub(-1) == "/" then
    path = path:sub(1, -2)
    if vim.fn.glob(path) == "" then
      cmd(string.format("%s %s %s", "!mkdir", "-p", fn.fnameescape(path)))
    end
  end

  -- attempt to add an extension and open
  if path:sub(-3) ~= ".md" and vim.fn.glob(path) == "" then
    modified_link = path .. ".md"
  else
    modified_link = path
  end

  if modified_link then
    if line_number then
      cmd(string.format("%s +%s %s", "e", line_number, fn.fnameescape(modified_link)))
    else
      cmd(string.format("%s %s", "e", fn.fnameescape(modified_link)))
    end
  end
end

local function follow_heading_link(link)
  link = link:gsub("-", "[- ]*")
  link = link:gsub("_", "[_ ]*")
  vim.fn.search("\\c^#\\+ *" .. link, 'ew')
end

local M = {}

function M.follow_link()
  local link_destination = get_link_destination()

  if link_destination then
    local resolved_link, link_type = resolve_link(link_destination)
    if link_type == "local" then
      follow_local_link(resolved_link)
    elseif link_type == "heading" then
      -- Save link position to jumplist
      cmd("normal! m'")
      follow_heading_link(resolved_link)
    elseif link_type == "man" then
      vim.cmd.Man(link_destination:gsub("man://", ""))
    elseif link_type == "web" then
      if is_linux then
        vim.system({ "xdg-open", resolved_link })
      elseif is_macos then
        vim.system({ "open", resolved_link })
      elseif is_windows then
        vim.system({ "cmd.exe", "/c", "start", "", resolved_link })
      end
    end
  end
end

return M
