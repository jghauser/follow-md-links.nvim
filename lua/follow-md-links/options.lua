local M = {}

M.options = {}

M.defaults = {
  ft = { 'markdown' },
  formatter = {
     heading_link = function(link)
        link = link:gsub("-", "[- ]*")
        link = link:gsub("_", "[_ ]*")
        return link
     end,
  },
}

function M.setup(user_opts)
   M.options = vim.tbl_deep_extend("force", {}, M.defaults, user_opts or {})
end

function M.get()
   return M.options
end

return M
