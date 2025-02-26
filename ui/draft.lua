local component = require("ui.badr")
local button    = require("ui.button")
local label     = require("ui.label")
local image     = require("ui.image")
local ui = require("ui.main")

local draft    = {}
local moduleDir = "champions/lua"
local spriteDir = "assets/champions"
local info = { champ = -1, slot = -1, champs = {}, slots = {} }
local picks = {blue = {}, red = {}}

local function sel_color(color)
  color[1] = 0.8
  color[2] = 0.6
  color[3] = 0.3
end

local function def_color(color)
  color[1] = 1
  color[2] = 1
  color[3] = 1
end

function draft:__call()
  local res = component { column = true, gap = 10, center = true }

  local bar = component { row = true, gap = 0, center = true }
    + label { text = "Blue side", color = {1, 1, 1}, bg = {0.2, 0.2, 0.8}, width = 640 }
    + label { text = "Red side", color = {1, 1, 1}, bg = {0.8, 0.2, 0.2}, width = 640, right = true }
  res = res + bar

  for _, file in ipairs(love.filesystem.getDirectoryItems(moduleDir)) do
    if file:match("%.lua$") then
      local name = file:gsub("%.lua$", "")
      table.insert(info.champs, {
        name = name,
        image = love.graphics.newImage(spriteDir .. "/" .. name .. ".jpg"),
        color = {1, 1, 1}
      })
    end
  end

  local champs = component { column = true, gap = 10 } + component {height = 40}
  local row
  local rowWidth = 6
  local font = love.graphics.newFont(18)

  for i, mod in pairs(info.champs) do
    if i % rowWidth == 1 then
        if row then
            champs = champs + row
        end
        row = component { row = true, gap = 40, center = true }
    end
    local id = i
    local item = component { column = true, center = true, gap = 5 }
    + (image { image = mod.image, width = 80, height = 80 } + button { text = "", width = 80, height = 80, onClick = function()
      if info.slot == -1 then
        if info.champ == id then
          info.champ = -1
          def_color(mod.color)
        else
          if not (info.champ == -1) then
            def_color(info.champs[info.champ].color)
          end
          info.champ = id
          sel_color(mod.color)
        end
      else
        info.slots[info.slot].image = mod.image
        def_color(info.slots[info.slot].color)
        picks[(is_blue and "blue" or "red")][info.slots[info.slot].text] = mod.name
        info.slot = -1
      end
    end} )
    + label { text = mod.name:gsub("^%l", string.upper), color = mod.color, font = font }
    row = row + item
  end
  champs = champs + row
  local slots = component { column = true, gap = 20}
  local champ_icon = love.graphics.newImage("assets/champ_icon.jpg")
  for i = 1, 5 do
    local row = component { row = true, gap = 1000}
    for _, is_blue in ipairs({ true, false }) do
        local label_text = (is_blue and "B" or "R") .. tostring(i)
        local col = {1, 1, 1}
        local mod = {image = champ_icon, color = {1, 1, 1}, text = label_text}
        table.insert(info.slots, mod)
        local id = #info.slots

        local slot = component { row = true, gap = 10, center = true }
            + (is_blue and label { text = label_text, color = mod.color } or nil)
            + (image { image = mod, width = 110, height = 110 }
                + button {
                    text = "", width = 110, height = 110,
                    onClick = function()
                        if info.champ == -1 then
                          if info.slot == id then
                            info.slot = -1
                            def_color(mod.color)
                          else
                            if not (info.slot == -1) then
                              def_color(info.slots[info.slot].color)
                            end
                            info.slot = id
                            sel_color(mod.color)
                          end
                        else
                          mod.image = info.champs[info.champ].image
                          picks[(is_blue and "blue" or "red")][label_text] = info.champs[info.champ].name
                          def_color(info.champs[info.champ].color)
                          info.champ = -1
                        end
                    end,
                    onRightClick = function()
                      mod.image = champ_icon
                      if info.slot == id then
                        def_color(mod.color)
                        info.slot = -1
                      end
                      picks[(is_blue and "blue" or "red")][label_text] = nil
                    end
                }
            )
            + (not is_blue and label { text = label_text, color = mod.color } or nil)
        row = row + slot
    end
    slots = slots + row
  end
  res = res + slots * champs
  res = res + button { text = "Play", onClick = function ()
    ui.set_draft(picks)
    ui.new_game()
  end}
  return res
end

return setmetatable(draft, draft)
