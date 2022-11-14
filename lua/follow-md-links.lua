--
-- FOLLOW MD LINKS
--

local fn = vim.fn
local cmd = vim.cmd
local loop = vim.loop
local ts_utils = require("nvim-treesitter.ts_utils")
local query = require("vim.treesitter.query")

local M = {}

local os_name = loop.os_uname().sysname
local is_windows = os_name == "Windows"
local is_macos = os_name == "Darwin"
local is_linux = os_name == "Linux"

local function get_reference_link_destination(link_label)
	local language_tree = vim.treesitter.get_parser(0)
	local syntax_tree = language_tree:parse()
	local root = syntax_tree[1]:root()
	local parse_query = vim.treesitter.parse_query("markdown", [[
  (link_reference_definition
    (link_label) @label (#eq? @label "]] .. link_label .. [[")
    (link_destination) @link_destination)
  ]])
	for _, captures, _ in parse_query:iter_matches(root, 0) do
		return query.get_node_text(captures[2], 0)
	end
end

local function get_link_destination()
	local node_at_cursor = ts_utils.get_node_at_cursor()
	local parent_node = node_at_cursor:parent()
	if not (node_at_cursor and parent_node) then
		return
	elseif node_at_cursor:type() == "link_destination" then
		return vim.split(query.get_node_text(node_at_cursor, 0), "\n")[1]
	elseif node_at_cursor:type() == "link_text" then
		local next_node = ts_utils.get_next_node(node_at_cursor)
		if next_node:type() == "link_destination" then
			return vim.split(query.get_node_text(next_node, 0), "\n")[1]
		elseif next_node:type() == "link_label" then
			local link_label = vim.split(query.get_node_text(next_node, 0), "\n")[1]
			return get_reference_link_destination(link_label)
		end
	elseif node_at_cursor:type() == "link_reference_definition" or node_at_cursor:type() == "inline_link" then
		local child_nodes = ts_utils.get_named_children(node_at_cursor)
		for _, node in pairs(child_nodes) do
			if node:type() == "link_destination" then
				return vim.split(query.get_node_text(node, 0), "\n")[1]
			end
		end
	elseif node_at_cursor:type() == "full_reference_link" then
		local child_nodes = ts_utils.get_named_children(node_at_cursor)
		for _, node in pairs(child_nodes) do
			if node:type() == "link_label" then
				local link_label = vim.split(query.get_node_text(node, 0), "\n")[1]
				return get_reference_link_destination(link_label)
			end
		end
	elseif node_at_cursor:type() == "link_label" then
		local link_label = vim.split(query.get_node_text(node_at_cursor, 0), "\n")[1]
		return get_reference_link_destination(link_label)
	else
		return
	end
end

local function resolve_link(link)
	local link_type
	if link:sub(1, 1) == [[/]] then
		link_type = "local"
		return link:gsub("%%20", " "), link_type
	elseif link:sub(1, 1) == [[~]] then
		link_type = "local"
		return os.getenv("HOME") .. [[/]] .. link:sub(2), link_type
	elseif link:sub(1, 8) == [[https://]] or link:sub(1, 7) == [[http://]] then
		link_type = "web"
		return link, link_type
	else
		link_type = "local"
		return fn.expand("%:p:h") .. [[/]] .. link:gsub("%%20", " "), link_type
	end
end

local function follow_local_link(link)
	local link = link
	local fd = loop.fs_open(link, "r", 438)
	if not fd then
		-- attempt to add an extension and open
		fd = loop.fs_open(link .. ".md", "r", 438)
		if fd then
			link = link .. ".md"
		end
	end

	if fd then
		local stat = loop.fs_fstat(fd)
		if not stat or not stat.type == "file" or not loop.fs_access(link, "R") then
			loop.fs_close(fd)
		else
			loop.fs_close(fd)
			cmd(string.format("%s %s", "e", fn.fnameescape(link)))
		end
	end
end

function M.follow_link()
	local link_destination = get_link_destination()

	if link_destination then
		local resolved_link, link_type = resolve_link(link_destination)
		if link_type == "local" then
			follow_local_link(resolved_link)
		elseif link_type == "web" then
			if is_linux then
				vim.fn.system("xdg-open " .. vim.fn.shellescape(resolved_link))
			elseif is_macos then
				vim.fn.system("open " .. vim.fn.shellescape(resolved_link))
			elseif is_windows then
				vim.fn.system('cmd.exe /c start "" ' .. vim.fn.shellescape(resolved_link))
			end
		end
	end
end

return M
