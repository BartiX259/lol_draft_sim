local ui = {}

love.graphics.setFont(love.graphics.newFont(require("ui.badr").FONT, 20))

ui.BLUE = 0
ui.RED = 1

ui.BLUE_COL = { 0.4, 0.4, 1 }
ui.RED_COL = { 1, 0.4, 0.4 }
ui.SEL_COL = { 0.8, 0.6, 0.3 }
ui.DEF_COL = { 1, 1, 1 }
ui.INACTIVE_COL = { 0.3, 0.3, 0.3 }

local NONE = 0
local DRAFT = 1
local GAME_END = 2
local SIM_END = 3
local RANDOM_SIM_END = 4

local STATE = NONE

local screen
local draft_screen

function ui.game_end(winner, blue_team, red_team)
  if STATE ~= GAME_END then
      print("Blue team:")
      for _, champ in pairs(blue_team) do
          print(champ.name .. ": " .. tostring(champ.damage_dealt))
      end
      print("Red team:")
      for _, champ in pairs(red_team) do
          print(champ.name .. ": " .. tostring(champ.damage_dealt))
      end
      STATE = GAME_END
      screen = require("ui.game_end")(winner, blue_team, red_team)
  end
  screen:fitScreen(0.6)
  screen:draw()
end

function ui.sim_end(sim_info)
  if STATE ~= SIM_END then
    STATE = SIM_END
    screen = require("ui.sim_end")(sim_info)
  end
  screen:fitScreen(0.6)
  screen:draw()
end

function ui.random_sim_end(sim_info)
  if STATE ~= RANDOM_SIM_END then
    STATE = RANDOM_SIM_END
    screen = require("ui.random_sim_end")(sim_info)
  end
  screen:fitScreen(0.6)
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
  screen:fitScreen(0.95)
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
