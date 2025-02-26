local ui = {}

ui.BLUE = 0
ui.RED = 1

local NONE = 0
local DRAFT = 1
local END_SCREEN = 2

local STATE = NONE

local screen
local draft_screen

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
  end
  screen:fitScreen()
  screen:draw()
end

function ui.draft()
  if STATE ~= DRAFT then
    STATE = DRAFT
    if not draft_screen then
      draft_screen = require("ui.draft")()
    end
    screen = draft_screen
  end
  screen:fitScreen()
  screen:draw()
end

function ui.clear()
  STATE = NONE
  screen = nil
end

function ui.update()
  if screen then
    screen:update()
  end
end

return ui
