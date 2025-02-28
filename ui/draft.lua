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

local function sel_color(mod)
  mod.color[1] = ui.SEL_COL[1]
  mod.color[2] = ui.SEL_COL[2]
  mod.color[3] = ui.SEL_COL[3]
  mod.borderColor[1] = ui.SEL_COL[1]
  mod.borderColor[2] = ui.SEL_COL[2]
  mod.borderColor[3] = ui.SEL_COL[3]
  mod.borderColor[4] = 1
end

local function def_color(mod)
  mod.color[1] = ui.DEF_COL[1]
  mod.color[2] = ui.DEF_COL[2]
  mod.color[3] = ui.DEF_COL[3]
  mod.borderColor[4] = 0
end

local function get_team(text)
  return string.find(text, "B") and "blue" or "red"
end

function draft:__call()
  local res = component { column = true, gap = 20, center = true }

  local bar = component { row = true, gap = 0, center = true }
    + label { text = "Blue side", color = ui.DEF_COL, bg = ui.BLUE_COL, width = 640 }
    + label { text = "Red side", color = ui.DEF_COL, bg = ui.RED_COL, width = 640, right = true }
  res = res + bar

  for _, file in ipairs(love.filesystem.getDirectoryItems(moduleDir)) do
    if file:match("%.lua$") then
      local name = file:gsub("%.lua$", "")
      table.insert(info.champs, {
        name = name,
        image = love.graphics.newImage(spriteDir .. "/" .. name .. ".jpg"),
        color = table.shallow_copy(ui.DEF_COL),
        borderColor = {0, 0, 0, 0}
      })
    end
  end

  local champs = component { column = true, gap = 10 } + component {height = 40}
  local row
  local rowWidth = 6
    local font = love.graphics.newFont(component.FONT, 14)

  for i, mod in pairs(info.champs) do
    if i % rowWidth == 1 then
        if row then
            champs = champs + row
        end
        row = component { row = true, gap = 40, center = true }
    end
    local id = i
    local item = component { column = true, center = true, gap = 5 }
    + (image { image = mod.image, width = 80, height = 80, borderRadius = 5, borderColor = mod.borderColor, borderWidth = 2 }
        + button { text = "", width = 120, height = 120, x = -20, y = 10,
    onClick = function()
      if info.slot == -1 then
        if info.champ == id then
          info.champ = -1
          def_color(mod)
        else
          if not (info.champ == -1) then
            def_color(info.champs[info.champ])
          end
          info.champ = id
          sel_color(mod)
        end
      else
        info.slots[info.slot].image = mod.image
        def_color(info.slots[info.slot])
        picks[get_team(info.slots[info.slot].text)][info.slots[info.slot].num] = mod.name
        info.slot = -1
      end
    end} )
    + label { text = mod.name:gsub("^%l", string.upper), color = mod.color, font = font, padding = 5 }
    row = row + item
  end
  champs = champs + row
  local slots = component { column = true, gap = 20}
  local champ_icon = love.graphics.newImage("assets/champ_icon.jpg")
  for i = 1, 5 do
    local row = component { row = true, gap = 1000}
    for _, is_blue in ipairs({ true, false }) do
        local label_text = (is_blue and "B" or "R") .. tostring(i)
        local team = is_blue and "blue" or "red"
        local num = i
        local mod = {image = champ_icon, color = table.shallow_copy(ui.DEF_COL), borderColor = {0, 0, 0, 0}, text = label_text, num = num}
        table.insert(info.slots, mod)
        local id = #info.slots
        
        local label_comp = label { text = label_text, color = mod.color, width = 50 }

        local slot = component { row = true, gap = 10, center = true }
            + (is_blue and label_comp or nil)
            + (image { image = mod, width = 110, height = 110, borderRadius = 5, borderColor = mod.borderColor, borderWidth = 4 }
                + button {
                    text = "yo", width = 110, height = 110, y = 20, bg = {1, 0, 0},
                    onClick = function()
                        if info.champ == -1 then
                          if info.slot == id then
                            info.slot = -1
                            def_color(mod)
                          else
                            if info.slot ~= -1 then
                              local other = info.slots[info.slot]
                              local other_team = get_team(other.text)
                              def_color(other)
                              if picks[other_team][other.num] or picks[team][num] then
                                -- Swap slots
                                local temp = mod.image
                                mod.image = other.image
                                other.image = temp
                                temp = picks[team][num]
                                picks[team][num] = picks[other_team][other.num]
                                picks[other_team][other.num] = temp
                                info.slot = -1
                                return
                              end
                            end
                            info.slot = id
                            sel_color(mod)
                          end
                        else
                          mod.image = info.champs[info.champ].image
                          picks[team][num] = info.champs[info.champ].name
                          def_color(info.champs[info.champ])
                          info.champ = -1
                        end
                    end,
                    onRightClick = function()
                      mod.image = champ_icon
                      if info.slot == id then
                        def_color(mod)
                        info.slot = -1
                      end
                      picks[team][num] = nil
                    end
                }
            )
            + (not is_blue and label_comp or nil)
        row = row + slot
    end
    slots = slots + row
  end
  res = res + slots * champs
  res = res + button { text = "Play", hoverColor = ui.SEL_COL,
    onClick = function ()
      ui.set_draft(picks)
      ui.new_game()
      end }
  res = res + button { text = "Simulate", hoverColor = ui.SEL_COL,
    onClick = function ()
      ui.set_draft(picks)
      ui.new_sim()
    end}
  return res
end

return setmetatable(draft, draft)
