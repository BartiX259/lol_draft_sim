local component = require("ui.badr")
local button    = require("ui.button")
local label     = require("ui.label")
local image     = require("ui.image")
local scroll_box = require("ui.scroll_box")
local ui = require("ui.main")
local search_bar = require("ui.search_bar")

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

local function to_title_case(s)
    return s:gsub("_", " "):gsub("(%a)(%w*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
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

  -- Search bar
  local offsets = {}
  local scaleFactor = 1
  local scroll_component
  res = res + component { width = 0, height = 0, scale = function (_, scale)
    scaleFactor = scaleFactor * scale
  end}
  res = res * search_bar { x = 25, y = 60, width = 400, center = true, font = love.graphics.newFont(component.font, 16), callback = function (text)
    local searchText = string.lower(text):gsub("[ ']", "")
    local i = 1
    for _, mod in pairs(info.champs) do
        if offsets[mod] ~= nil then
          mod.component:updatePosition(-offsets[mod].x * scaleFactor, -offsets[mod].y * scaleFactor)
          offsets[mod] = nil
        end
        local modName = string.lower(mod.name):gsub("_", "")
        if modName:sub(1, #searchText) == searchText then
          offsets[mod] = {
            x = info.champs[i].component.x - mod.component.x,
            y = info.champs[i].component.y - mod.component.y
          }
          mod.component:updatePosition(offsets[mod].x, offsets[mod].y)
          offsets[mod].x = offsets[mod].x / scaleFactor
          offsets[mod].y = offsets[mod].y / scaleFactor
          mod.component.visible = true
          i = i + 1
        else
          mod.component.visible = false
        end
    end
    local delta = -scroll_component.child_y
    scroll_component:updatePosition(0, delta)
    scroll_component.child_y = scroll_component.child_y + delta
    scroll_component.y = scroll_component.y - delta
    if i < 20 then
      scroll_component.freeze = true
    else
      scroll_component.freeze = false
    end
  end
  }

  -- Champions
  local champs = component { column = true, gap = 10 } + component { height = 20 }
  local row
  local rowWidth = 6
  local font = love.graphics.newFont(component.font, 14)
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
    + label { text = to_title_case(mod.name), color = mod.color, font = font, padding = 5 }
    mod.component = item
    row = row + item
  end
  champs = champs + row
  champs = scroll_box { height = 590, offsetTop = -20 } + champs
  scroll_component = champs

  -- Slots
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
    local item = component { row = true, gap = 0 } + (component { column = true, center = true, gap = 30 }
    + button { text = "Test winrates", hoverColor = ui.SEL_COL,
    onClick = function ()
      ui.set_base_draft(picks)
      ui.random_sim()
    end}
   + button { text = "Find best", hoverColor = ui.SEL_COL,
    onClick = function ()
      ui.set_base_draft(picks)
      ui.find_best()
    end}) + component {width = 50}
    res = res + item
  return res
end

return setmetatable(draft, draft)
