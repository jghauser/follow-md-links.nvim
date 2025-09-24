local M = {}

function M.create_commands()
   opts = require("follow-md-links.options").get()

   vim.api.nvim_create_autocmd("FileType", {
      pattern = opts.ft,
      callback = function()
         vim.api.nvim_buf_create_user_command(0, "FollowMdLinks", function()
            print("FollowMdLinks command invoked before")
            require("follow-md-links").follow_link()
            print("FollowMdLinks command invoked after")
         end, { desc = "Follow markdown link under cursor" })
      end,
   })
end

return M
