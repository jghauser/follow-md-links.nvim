{
  self,
  name,
}:
final: prev:
let
  mkNvimMinimal =
    nvim:
    with final;
    let
      neovimConfig = neovimUtils.makeNeovimConfig {
        withPython3 = false;
        viAlias = true;
        vimAlias = true;
        extraLuaPackages = luaPkgs: [
          luaPkgs.follow-md-links-nvim
        ];
      };
      runtimeDeps = [ ];
    in
    final.wrapNeovimUnstable nvim (
      neovimConfig
      // {
        wrapperArgs =
          lib.escapeShellArgs neovimConfig.wrapperArgs
          + " "
          + ''--set NVIM_APPNAME "nvim-${name}"''
          + " "
          + ''--prefix PATH : "${lib.makeBinPath runtimeDeps}"'';
        wrapRc = true;
        neovimRcContent =
          # lua
          ''
            lua << EOF
            local o = vim.o
            local cmd = vim.cmd
            local fn = vim.fn
            local keymap = vim.keymap

            -- disable swap
            o.swapfile = false

            -- add current directory to runtimepath to have the plugin
            -- be loaded from the current directory
            vim.opt.runtimepath:prepend(vim.fn.getcwd())

            -- remap leader
            vim.g.mapleader = " "

            ---Sets up keymap for follow-md-links.nvim
            vim.api.nvim_create_autocmd("BufEnter", {
              pattern = "*.md",
              callback = function()
                keymap.set('n', '<bs>', ':edit #<cr>', { silent = true })
              end,
              group = vim.api.nvim_create_augroup("setFollowMdLinksKeymap", {}),
              desc = "Set keymap for follow-md-links",
            })
            EOF
          '';
      }
    );
in
{
  neovim-with-plugin = mkNvimMinimal final.neovim-unwrapped;
}
