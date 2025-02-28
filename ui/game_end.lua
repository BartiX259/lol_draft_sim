local component = require("ui.badr")
local button    = require("ui.button")
local label     = require("ui.label")
local image     = require("ui.image")
local graph     = require("ui.graph")
local ui        = require("ui.main")

local game_end    = {}

function game_end:__call(winner, blue_team, red_team)
  love.graphics.setFont(love.graphics.newFont(component.FONT, 20))
  local content
  if winner == ui.BLUE then
    content = "Blue Wins"
  else
    content = "Red Wins"
  end
  local res = component { column = true, gap = 20, center = true }
      + label { text = content, color = { 1, 1, 1 } }
      + button { text = "Play", hoverColor = ui.SEL_COL, onClick = function()
        ui.new_game()
        end }
      + button { text = "Simulate", hoverColor = ui.SEL_COL, onClick = function()
        ui.new_sim()
      end }
       + button { text = "Draft", hoverColor = ui.SEL_COL, onClick = function()
        ui.draft_mode()
      end }
      + label { text = "" }
      + graph("damage_dealt", blue_team, red_team)
  res = component { row = true, center = true } + res -- Center vertically
  return res
end

return setmetatable(game_end, game_end)
