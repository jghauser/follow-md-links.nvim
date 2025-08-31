{
  name,
  self,
}: final: prev: let
  follow-md-links-nvim-luaPackage-override = luaself: luaprev: {
    follow-md-links-nvim = luaself.callPackage ({
      buildLuarocksPackage,
      lua,
      luaOlder,
    }:
      buildLuarocksPackage {
        pname = name;
        version = "scm-1";
        knownRockspec = "${self}/${name}-scm-1.rockspec";
        disabled = luaOlder "5.1";
        src = self;
      }) {};
  };

  lua5_1 = prev.lua5_1.override {
    packageOverrides = follow-md-links-nvim-luaPackage-override;
  };
  lua51Packages = prev.lua51Packages // final.lua5_1.pkgs;
  luajit = prev.luajit.override {
    packageOverrides = follow-md-links-nvim-luaPackage-override;
  };
  luajitPackages = prev.luajitPackages // final.luajit.pkgs;
in {
  inherit
    lua5_1
    lua51Packages
    luajit
    luajitPackages
    ;

  vimPlugins =
    prev.vimPlugins
    // {
      follow-md-links-nvim = final.neovimUtils.buildNeovimPlugin {
        pname = name;
        src = self;
        version = "dev";
      };
    };
}
