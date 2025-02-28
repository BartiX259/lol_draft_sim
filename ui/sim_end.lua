local component = require("ui.badr")
local button    = require("ui.button")
local label     = require("ui.label")
local image     = require("ui.image")
local graph     = require("ui.graph")
local ui        = require("ui.main")

local sim_end    = {}

function sim_end:__call(info)
    love.graphics.setFont(love.graphics.newFont(component.FONT, 20))
    local res = component { column = true, gap = 20, center = true }
      + (component { row = true, gap = 100 }
      + label { text = "Blue wins: ".. tostring(info.blue_wins), color = { 1, 1, 1 } }
      + label { text = "Red wins: ".. tostring(info.red_wins), color = { 1, 1, 1 } }
        )
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
      + graph("damage_dealt", info.blue, info.red)
  res = component { row = true, center = true } + res -- Center vertically
  return res
end

return setmetatable(sim_end, sim_end)
