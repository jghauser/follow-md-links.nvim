local M = {}

local opts_module = require("follow-md-links.options")
local core_module = require("follow-md-links.core")
local cmd_module = require('follow-md-links.commands')

function M.setup(user_opts)
   opts_module.setup(user_opts)
   cmd_module.create_commands()
end

M.follow_link = core_module.follow_link

return setmetatable(M, {
  __call = function(_, ...)
    M.setup(...)
  end,
})
