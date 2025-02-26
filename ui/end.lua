local component = require("ui.badr")
local button    = require("ui.button")
local label     = require("ui.label")
local image     = require("ui.image")
local ui        = require("ui.main")

local end_ui    = {}

function end_ui:__call(winner, blue_team, red_team)
  local content
  if winner == ui.BLUE then
    content = "Blue Wins"
  else
    content = "Red Wins"
  end
  local res = component { column = true, gap = 10, center = true }
      + label { text = content, color = { 1, 1, 1 } }
      + button { text = "Restart", onClick = function()
        ui.new_game()
      end }
       + button { text = "Draft", onClick = function()
        ui.draft_mode()
      end }
      + label { text = "" }
      + label { text = "Blue team", color = { 1, 1, 1 } }
  for _, champ in pairs(blue_team) do
    res = res + (component { row = true, gap = 10, center = true }
      + label { text = champ.name, color = { 1, 1, 1 } }
      + image { image = champ.sprite, width = 40, height = 40 }
      + label { text = tostring(champ.damage_dealt), color = { 1, 1, 1 } })
  end
  res = res
      + label { text = "" }
      + label { text = "Red team", color = { 1, 1, 1 } }
  for _, champ in pairs(red_team) do
    res = res + (component { row = true, gap = 10 }
      + label { text = champ.name, color = { 1, 1, 1 } }
      + image { image = champ.sprite, width = 40, height = 40 }
      + label { text = tostring(champ.damage_dealt), color = { 1, 1, 1 } })
  end
  res = component { row = true, center = true } + res -- Center vertically
  return res
end

return setmetatable(end_ui, end_ui)
