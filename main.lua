
-- modify path to find files correctly on macos/linux
package.cpath = package.cpath .. ';' .. love.filesystem.getSourceBaseDirectory() .. '/?.so'
package.cpath = package.cpath .. ';' .. love.filesystem.getSourceBaseDirectory() .. '/?.dylib'
package.cpath = package.cpath .. ';' .. love.filesystem.getSourceBaseDirectory() .. '/?.dll'

love.graphics.setDefaultFilter("nearest", "nearest", 1)
love.keyboard.setTextInput(true)

_G.utf8 = require("utf8")
_G.json = require('json')

_G.colors = {
  grey1 = {0.09, 0.1, 0.1},
  grey2 = {0.19, 0.2, 0.2},
  grey3 = {0.29, 0.3, 0.3},
  grey4 = {0.39, 0.4, 0.4},
  green1 = {0.2, 0.5, 0.2},
  white = {1, 1, 1}
}

_G.modloader = {

  g = {
    steam = require('luasteam'),
    status = 'loading',
    error = '',
    highlighted_item = '',
    highlighted_ui = '',
    popup = 0,
    selected = '',
    upload = nil,
    input = '',
    x = 0,
    y = 0,
    items = {
      {
        id = nil,
        text = '',
        type = 'gui',
        version = 0,
        status = '',
        reset = 0,
        x = 0,
        y = 0,
        w = 640,
        h = 480,
        visible = false,
        ui = {
          {
            type = 'local',
            text = 'Edit Config',
            x = 420,
            y = 10,
            w = 100,
            h = 30
          },
          {
            type = 'new',
            text = 'Create New',
            x = 530,
            y = 10,
            w = 100,
            h = 30,
            color = 'green1'
          }
        }
      }
    },
  },

  loadData = function()
    local raw = love.filesystem.read('mods.json')
    print('loadData', raw)
    if raw ~= nil then
      local data = json.decode(raw)
      for d=1,#data do
        modloader.insertItem(data[d].id, data[d].title, data[d].version)
      end
    else
      love.filesystem.write('mods.json', '[]')
    end
    modloader.g.status = ''
  end,

  saveData = function()
    local items = {}
    for i=1,#modloader.g.items do
      local item = modloader.g.items[i]
      if item.type ~= 'gui' then
        table.insert(items, {
          id = item.id,
          title = item.text,
          version = item.version or 0
        })
      end
    end
    local data = json.encode(items)
    love.filesystem.write('mods.json', data)
  end,

  createItem = function(data, err)
    if not err then
      modloader.insertItem(tostring(data.publishedFileId), 'NEW MOD', 0)
      modloader.saveData()
    end
  end,

  insertItem = function(id, text, version)
    local newitem = {
      id = id,
      text = text,
      type = 'item',
      version = version,
      status = '',
      reset = 0,
      x = 10,
      y = (#modloader.g.items*50) + ((#modloader.g.items-1)*10),
      w = 620,
      h = 50,
      visible = true,
      ui = {
        {
          type = 'title',
          text = 'Set Title',
          x = 180,
          y = 10,
          w = 100,
          h = 30
        },
        {
          type = 'icon',
          text = 'Set Icon',
          x = 290,
          y = 10,
          w = 100,
          h = 30
        },
        {
          type = 'upload',
          text = 'Upload Mod',
          x = 400,
          y = 10,
          w = 100,
          h = 30
        },
        {
          type = 'link',
          text = 'View Item',
          x = 510,
          y = 10,
          w = 100,
          h = 30
        }
      }
    }
    table.insert(modloader.g.items, newitem)
  end,

  updateItem = function()
    modloader.saveData()
  end


}

love.load = function()
  
  local initialised = modloader.g.steam.init()
  if not initialised then
    print('Steam Not Initialised')
    modloader.g.status = 'error'
    modloader.g.error = 'Failed to initialise Steam!'
  else
    print('Steam Initialised', modloader.g.steam.utils.getAppID())
    modloader.loadData()
    love.filesystem.write('modding_guide.txt', 'https://steamcommunity.com/sharedfiles/filedetails/?id=3412885981')
  end

end

love.textinput = function(text)
  if modloader.g.popup then
    modloader.g.input = modloader.g.input .. text
    print(modloader.g.input)
  end
end

local drawUI = function(ui_list, item)
  for u=1,#ui_list do
    local ui = ui_list[u]
    if ui.color then
      love.graphics.setColor(colors[ui.color])
    else
      love.graphics.setColor(colors.grey3)
    end
    love.graphics.rectangle('fill', item.x+ui.x, item.y+ui.y, ui.w, ui.h)
    if ui == modloader.g.highlighted_ui then
      love.graphics.setColor(colors.white)
      love.graphics.rectangle('line', item.x+ui.x, item.y+ui.y, ui.w, ui.h)
    end
    love.graphics.setColor(colors.white)
    love.graphics.printf(ui.text, item.x+ui.x, item.y+ui.y+5, ui.w, 'center')
  end
end
local drawItem = function(item)
  if item.visible then
    if item == modloader.g.highlighted_item then
      love.graphics.setColor(colors.grey2)
    else
      love.graphics.setColor(colors.grey1)
    end
    love.graphics.rectangle('fill', item.x, item.y, item.w, item.h)
    love.graphics.setColor(colors.white)
    love.graphics.print(item.text, item.x+8, item.y+5)
    love.graphics.setColor(colors.grey4)
    if item.status ~= '' then
      love.graphics.print(item.status, item.x+8, item.y+5 + 20)
    else
      love.graphics.print(item.id, item.x+8, item.y+5 + 20)
    end
  end
  if item.ui then
    drawUI(item.ui, item)
  end
end

love.draw = function()
  if modloader.g.status == 'loading' then
    love.graphics.print('Loading...', 10, 10)
  elseif modloader.g.status == 'error' then
    love.graphics.print(modloader.g.error, 10, 10)
  else
    love.graphics.setColor(colors.white)
    love.graphics.print('Your Workshop Items', 10, 15)
    for i=1,#modloader.g.items do
      drawItem(modloader.g.items[i])
    end
    if modloader.g.popup > 0 then
      love.graphics.setColor(0, 0, 0, 0.8)
      love.graphics.rectangle('fill', 0, 0, 640, 480)
      love.graphics.setColor(colors.white)
      love.graphics.printf('Type a title and press enter', 220, 215, 200, 'center')
      love.graphics.setColor(colors.grey1)
      love.graphics.rectangle('fill', 220, 235, 200, 30)
      love.graphics.setColor(colors.green1)
      love.graphics.print(modloader.g.input, 230, 240)
    end
  end
end

love.keypressed = function(k)
  if modloader.g.popup > 0 then
    if k == 'backspace' then
      local byteoffset = utf8.offset(modloader.g.input, -1)
      if byteoffset ~= nil then
        modloader.g.input = modloader.g.input:sub(1, byteoffset - 1)
      end
    end
    if k == 'return' then
      -- set title
      if modloader.g.popup == 1 then
        local item_uuid = modloader.g.steam.extra.parseUint64(modloader.g.selected.id)
        modloader.g.upload = {
          item = modloader.g.selected,
          stream = modloader.g.steam.UGC.startItemUpdate(modloader.g.steam.utils.getAppID(), item_uuid)
        }
        modloader.g.steam.UGC.setItemTitle(modloader.g.upload.stream, modloader.g.input)
        modloader.g.steam.UGC.submitItemUpdate(modloader.g.upload.stream, nil, modloader.updateItem)
        modloader.g.selected.text = modloader.g.input
        modloader.g.popup = 0
      end
    end
  end
end


love.update = function(dt)
  local mouse_x = love.mouse.getX()
  local mouse_y = love.mouse.getY()
  local highlighted_item = nil
  local highlighted_ui = nil
  for i=1,#modloader.g.items do
    local item = modloader.g.items[i]
    if mouse_x >= item.x and mouse_x <= item.x+item.w
    and mouse_y >= item.y and mouse_y <= item.y+item.h then
      highlighted_item = item
      for u=1,#item.ui do
        local ui = item.ui[u]
        if mouse_x >= item.x+ui.x and mouse_x <= item.x+ui.x+ui.w
        and mouse_y >= item.y+ui.y and mouse_y <= item.y+ui.y+ui.h then
          highlighted_ui = ui
        end
      end
    end
    if item.reset > 0 then
      item.reset = item.reset - dt
      if item.reset <= 0 then
        item.status = ''
      end
    end
  end
  modloader.g.highlighted_item = highlighted_item
  modloader.g.highlighted_ui = highlighted_ui
  if modloader.g.upload ~= nil then
    local status, bytes, total = modloader.g.steam.UGC.getItemUpdateProgress(modloader.g.upload.stream)
    if status ~= 'Invalid' then
      modloader.g.upload.item.status = status .. ' (' .. tostring(bytes) .. 'b / ' .. tostring(total) .. 'b)'
    else
      modloader.g.upload.item.status = 'Content Uploaded!'
      modloader.g.upload.item.reset = 1
      modloader.g.upload = nil
    end
  end
  modloader.g.steam.runCallbacks()
end

love.mousepressed = function()
  local item = modloader.g.highlighted_item
  local ui = modloader.g.highlighted_ui
  modloader.g.selected = item
  if modloader.g.popup > 0 then modloader.g.popup = 0 end
  if ui ~= nil then
    -- item links
    if ui.type == 'link' and item ~= nil then
      love.system.openURL('https://steamcommunity.com/sharedfiles/filedetails/?id=' .. item.id)
    end
    -- item upload
    if ui.type == 'upload' and item ~= nil then
      love.window.showFileDialog('openfolder', function(res, filter, err)
        if err then print(err) end
        local folder_path = res[1]
        local item_uuid = modloader.g.steam.extra.parseUint64(item.id)
        print('upload folder', folder_path, item_uuid)
        modloader.g.upload = {
          item = item,
          stream = modloader.g.steam.UGC.startItemUpdate(modloader.g.steam.utils.getAppID(), item_uuid)
        }
        modloader.g.steam.UGC.setItemContent(modloader.g.upload.stream, folder_path)
        modloader.g.steam.UGC.submitItemUpdate(modloader.g.upload.stream, nil, modloader.updateItem)
        item.version = 1
      end, {
        title = 'Select the folder containing your mod.lua!'
      })
    end
    -- item set icon
    if ui.type == 'icon' and item ~= nil then
      love.window.showFileDialog('openfile', function(res, filter, err)
        if err then print(err) end
        local file_path = res[1]
        local item_uuid = modloader.g.steam.extra.parseUint64(item.id)
        print('upload folder', file_path, item_uuid)
        modloader.g.upload = {
          item = item,
          stream = modloader.g.steam.UGC.startItemUpdate(modloader.g.steam.utils.getAppID(), item_uuid)
        }
        modloader.g.steam.UGC.setItemPreview(modloader.g.upload.stream, file_path)
        modloader.g.steam.UGC.submitItemUpdate(modloader.g.upload.stream, nil, modloader.updateItem)
      end, {
        title = 'Select the file to use!'
      })
    end
    -- create new item
    if ui.type == 'new' then
      local x, y, z = modloader.g.steam.UGC.createItem(modloader.g.steam.utils.getAppID(), 'Community', modloader.createItem)
      --modloader.g.popup = true
      --modloader.g.input = ''
    end
    -- add existing from id
    if ui.type == 'local' then
      love.system.openURL('file://' .. love.filesystem.getSaveDirectory())
    end
    -- set title
    if ui.type == 'title' then
      modloader.g.popup = 1
      modloader.g.input = ''
    end
  end
end
