-- @file - build.lua
-- @desc - build configuration for export using
--         https://github.com/ellraiser/love-build
return {
  name = 'Mudloader',
  developer = 'ellraiser',
  output = 'dist',
  version = '0.1.0',
  love = '12.0',
  icon = 'icon.png',
  identifier = 'com.ellraiser.mudloader',
  libs = {
    windows = {
      'steam/windows/luasteam.dll',
      'steam/windows/steam_api64.dll',
      'steam_appid.txt',
    },
    macos = {
      'steam/macos/luasteam.so',
      'steam/macos/libsteam_api.dylib',
      'steam_appid.txt',
    },
    linux = {
      'steam/linux/luasteam.so',
      'steam/linux/libsteam_api.so',
      'steam_appid.txt',
    }
  },
  ignore = {
    'dist', '.vscode', 'example_mod', 'steam'
  }
}
