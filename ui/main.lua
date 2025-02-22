local ui = {}

ui.BLUE = 0
ui.RED = 1

local NONE = 0
local END_SCREEN = 1

local STATE = NONE

local screen

love.graphics.setFont(love.graphics.newFont(25))

function ui.end_screen(winner, blue_team, red_team)
  if STATE ~= END_SCREEN then
    print("Blue team:")
    for _, champ in pairs(blue_team) do
      print(champ.name .. ": " .. tostring(champ.damage_dealt))
    end
    print("Red team:")
    for _, champ in pairs(red_team) do
      print(champ.name .. ": " .. tostring(champ.damage_dealt))
    end
    STATE = END_SCREEN
    screen = require("ui.end")(winner, blue_team, red_team)
    screen:updatePosition(
      love.graphics.getWidth() * 0.5,
      love.graphics.getHeight() * 0.5
    )
  end
  screen:draw()
end

function ui.clear()
  STATE = NONE
  screen = nil
end

function ui.update()
  screen:update()
end

return ui
