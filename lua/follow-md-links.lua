--
-- FOLLOW MD LINKS
--

local fn = vim.fn
local cmd = vim.cmd
local loop = vim.loop
local ts_utils = require("nvim-treesitter.ts_utils")
local query = require("vim.treesitter.query")
local treesitter = require("vim.treesitter")

function string:startswith(start)
   return self:sub(1, #start) == start
end

local os_name = loop.os_uname().sysname
local is_windows = os_name:startswith("Windows")
local is_macos = os_name == "Darwin"
local is_linux = os_name == "Linux"

local function get_reference_link_destination(link_label)
   local language_tree = vim.treesitter.get_parser(0)
   local syntax_tree = language_tree:parse()
   local root = syntax_tree[1]:root()
   local parsed_query = vim.treesitter.query.parse("markdown", [[
  (link_reference_definition
    (link_label) @label (#eq? @label "]] .. link_label .. [[")
    (link_destination) @link_destination)
  ]])
   -- Problem with handling whitespace in filenames elegently is with this iter_matches
   for _, captures, _ in parsed_query:iter_matches(root, 0) do
      local node_text = treesitter.get_node_text(captures[2], 0)
      -- Kludgy method right now is to require that filenames with spaces are wrapped in <>,
      -- which are stripped out after the matching is complete
      return string.gsub(node_text, "[<>]", "")
      --return treesitter.get_node_text(captures[2], 0)
   end
end

local function get_link_destination()
   local node = ts_utils.get_node_at_cursor()
   if not node then
      return
   end

   local candidates = { node }
   local parent = node:parent()
   if parent then
      table.insert(candidates, parent)
   end

   for _, n in ipairs(candidates) do
      local t = n:type()
      if t == "link_destination" then
         return vim.split(treesitter.get_node_text(n, 0), "\n")[1]
      elseif t == "shortcut_link" then
         local text = vim.split(treesitter.get_node_text(n, 0), "\n")[1]
         return get_reference_link_destination(text)
      elseif t == "link_text" then
         local next_node = ts_utils.get_next_node(n)
         if next_node then
            local nt = next_node:type()
            if nt == "link_destination" or nt == "link_label" then
               local text = vim.split(treesitter.get_node_text(next_node, 0), "\n")[1]
               if nt == "link_destination" then
                  return text
               else
                  return get_reference_link_destination(text)
               end
            end
         end
      elseif t == "link_reference_definition" or t == "inline_link" or t == "full_reference_link" then
         for _, child in ipairs(ts_utils.get_named_children(n)) do
            if child:type() == "link_destination" then
               return vim.split(treesitter.get_node_text(child, 0), "\n")[1]
            elseif child:type() == "link_label" then
               local label = vim.split(treesitter.get_node_text(child, 0), "\n")[1]
               return get_reference_link_destination(label)
            end
         end
      elseif t == "link_label" then
         local label = vim.split(treesitter.get_node_text(n, 0), "\n")[1]
         return get_reference_link_destination(label)
      end
   end
end

local function resolve_link(link)
   local link_type
   local anchor
   if link:sub(1, 8) == [[https://]] or link:sub(1, 7) == [[http://]] then
      link_type = "web"
      return link, link_type, nil
   elseif link:sub(1, 1) == [[#]] then
      link_type = "anchor"
      return link:sub(2), link_type, link:sub(2)
   elseif link:sub(1, 1) == [[/]] then
      link_type = "local"
   elseif link:sub(1, 1) == [[~]] then
      link_type = "local"
      link = os.getenv("HOME") .. [[/]] .. link:sub(2)
   else
      link_type = "local"
      link = fn.expand("%:p:h") .. [[/]] .. link
   end
   anchor = link:match("#(.+)")
   link = link:match("^([^#]+)")
   return link, link_type, anchor
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

local function follow_anchor_link(link)
   link = link:gsub("-", "[- ]*")
   link = link:gsub("_", "[_ ]*")
   vim.fn.search("\\c^#\\+ *" .. link, "ew")
end

local M = {}

function M.follow_link()
   local link_destination = get_link_destination()

   if link_destination then
      local resolved_link, link_type, anchor = resolve_link(link_destination)
      if link_type == "local" then
         follow_local_link(resolved_link)
         if anchor then
            follow_anchor_link(anchor)
         end
      elseif link_type == "anchor" then
         follow_anchor_link(resolved_link)
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
