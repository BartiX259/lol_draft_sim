require("util.extensions")
local vec2 = require("util.vec2")
local distances = require("util.distances")
local ui = require("ui.main")
local dump = require("util.dump")
local camera = require("util.camera")

local PLAYING = 0
local BLUE_WIN = 1
local RED_WIN = 2
local DRAFT = 3
local GLITCH = 4

function love.load()
  love.window.setMode(1000, 600, {resizable = true})
  love.window.maximize()
 Draft = {blue = {}, red = {}}
 GameState = DRAFT
end

function set_draft(draft)
  Draft = draft
end

function draft()
  GameState = DRAFT
end

function new_game()
  GameState = PLAYING
  Camera = camera(0, 0)
  Camera:zoom(0.4)
  ui.clear()
  BlueTeam = {}
  RedTeam = {}
    x = -600
  for _, champ in pairs(Draft.blue) do
     table.insert(BlueTeam, require("champions.lua."..champ).new(x, 1100))
     x = x + 200
  end
  x = -600
  for _, champ in pairs(Draft.red) do
     table.insert(RedTeam, require("champions.lua."..champ).new(x, -1100))
     x = x + 200
  end
  BlueProjectiles = {}
  RedProjectiles = {}
  Capture = 0
  CaptureRadius = 200
  CaptureSpeed = 0.05
  CaptureFade = CaptureSpeed / 2
  Delays = {}
  BlueTeamAll = table.shallow_copy(BlueTeam)
  RedTeamAll = table.shallow_copy(RedTeam)
end

ui.new_game = new_game
ui.set_draft = set_draft
ui.draft_mode = draft

function SpawnBlue(projectile)
  table.insert(BlueProjectiles, projectile)
end

function SpawnRed(projectile)
  table.insert(RedProjectiles, projectile)
end

function Delay(time, func)
  table.insert(Delays, { time = time, func = func })
end

function love.update(dt)
  if GameState == GLITCH then
    return
  end

  if GameState ~= PLAYING then
      ui.update()
      return
  end

  if Capture >= 1 or rawequal(next(RedTeam), nil) then
      GameState = BLUE_WIN
      ui.update()
      return
  elseif Capture <= -1 or rawequal(next(BlueTeam), nil) then
      GameState = RED_WIN
      ui.update()
      return
  end

  -- Handle delays
  for id, delay in pairs(Delays) do
    delay.time = delay.time - dt
    if delay.time <= 0 then
      delay.func()
      table.remove(Delays, id)
    end
  end

  local objective_count = 0
  -- Update champions
  for _, team in ipairs({ { BlueTeam, RedTeam, true }, { RedTeam, BlueTeam, false } }) do
    local allies, enemies, is_blue = team[1], team[2], team[3]

    for _, champ in pairs(allies) do
      -- Context for champion
      local context = {
        allies = allies,
        enemies = enemies,
        champ = champ,
        projectiles = is_blue and RedProjectiles or BlueProjectiles,
        closest_ally = distances.find_closest(champ, allies),
        closest_enemy = distances.find_closest(champ, enemies),
        allies_avg_pos = distances.weighted_position(champ, allies),
        enemies_avg_pos = distances.weighted_position(champ, enemies),
        capture = Capture,
        spawn = is_blue and SpawnBlue or SpawnRed,
        delay = Delay,
        dt = dt
      }
      if context.closest_enemy == nil then
        GameState = GLITCH
        return
      end
      context.closest_dist = context.closest_enemy.pos:distance(champ.pos)
      if champ.pos:mag() < CaptureRadius then
        local dir = is_blue and 1 or -1
        objective_count = objective_count + dir
      end
      local move_mult = 1
      local can_cast = true
      -- Effects
      for id, effect in pairs(champ.effects) do
        if effect:tick(context) then
          table.remove(champ.effects, id)
          if effect.on_finish_func ~= nil then
            effect.on_finish_func()
          end
        else
          if effect.tags["stun"] then
            move_mult = 0
            can_cast = false
          end
          if effect.tags["silence"] then
            can_cast = false
          end
          if effect.tags["root"] then
            move_mult = 0
          end
          if effect.tags["slow"] or effect.tags["speed"] then
            move_mult = move_mult * effect.amount
          end
        end
      end

      local ready_abilities = {}
      -- Abilities
      if can_cast then
        for name, ability in pairs(champ.abilities) do
          local check = false
          if ability.joined then
            if ability.joined.active then
              if not ability.joined_use then
                check = true
              end
            else
              ability.joined_use = false
            end
          elseif ability:tick(dt) then
              check = true
          end
          if check then
            local cast = ability:cast(context)
            if cast then
              ability:use(context, cast)
              if ability.joined then
                ability.joined_use = true
              else
                ability.timer = ability.cd
              end
            else
              ready_abilities[name] = true
            end
          end
        end
      end

      -- Behaviour
      champ.behaviour(ready_abilities, context)

      -- Movement
      if champ.target ~= nil and champ.target.pos:distance(champ.pos) > champ.range / 2 then
        champ.move_dir = champ.target.pos - champ.pos
      elseif champ.random:tick(context.dt) then
        champ:move(context)
      end
      champ.pos = champ.pos + champ.move_dir:normalize() * dt * champ.ms * move_mult
    end
  end

  -- Update projectiles
  for _, list in ipairs({ BlueProjectiles, RedProjectiles }) do
    for id, projectile in pairs(list) do
      if projectile:update(dt) then
        -- Despawn logic
        if projectile.after ~= nil then
          projectile.after()
        end
        if projectile.next ~= nil then
          if projectile.next.pos == nil then
            projectile.next.pos = projectile.pos
          end
          list[id] = projectile.next
          projectile.ability.proj = projectile.next
        else
          projectile.ability.proj = nil
          table.remove(list, id)
        end
      end
    end
  end

  -- Check death
  for _, team in ipairs({ BlueTeam, RedTeam }) do
    for i = #team, 1, -1 do
      if team[i].health <= 0 then
        table.remove(team, i)
      end
    end
  end

  -- Update objective
  if objective_count == 0 then
    local dir = Capture > 0 and -1 or 1
    Capture = Capture + dir * math.min(math.abs(Capture), CaptureFade * dt)
  else
    local dir = objective_count / (1 + math.abs(objective_count) / 4)
    Capture = Capture + dir * CaptureSpeed * dt
  end
end

function love.draw()
  -- UI
  if GameState == DRAFT then
    ui.draft()
    return
  end
  if GameState == BLUE_WIN then
    ui.end_screen(ui.BLUE, BlueTeamAll, RedTeamAll)
    return
  end
  if GameState == RED_WIN then
    ui.end_screen(ui.RED, BlueTeamAll, RedTeamAll)
    return
  end

  Camera:attach()

  -- Objective
  love.graphics.setColor({ 1, 1, 1, 1 })
  love.graphics.arc("fill", 0, 0, CaptureRadius + 10, -math.pi / 2, -math.pi / 2 + Capture * 2 * math.pi)
  if Capture > 0 then
    love.graphics.setColor({ 0.3, 0.3, 0.6 })
  elseif Capture < 0 then
    love.graphics.setColor({ 0.6, 0.3, 0.3 })
  else
    love.graphics.setColor({ 0.4, 0.4, 0.4 })
  end
  love.graphics.circle("fill", 0, 0, CaptureRadius)

  -- Draw projectiles
  for _, list in ipairs({ BlueProjectiles, RedProjectiles }) do
    for _, projectile in pairs(list) do
      projectile:draw()
    end
  end

  -- Iterate over both teams
  for _, team in ipairs({ { BlueTeam, { 0.6, 0.6, 1 } }, { RedTeam, { 1, 0.6, 0.6 } } }) do
    local champs, color = team[1], team[2]

    -- Draw champions
    love.graphics.setColor(color)
    for _, champ in pairs(champs) do
      love.graphics.setColor(color)
      if champ:has_effect("stun") then
        love.graphics.setColor({ 1000, 1000, 1000 })
      end
      love.graphics.line(champ.pos.x, champ.pos.y, champ.pos.x + champ.move_dir.x, champ.pos.y + champ.move_dir.y)
      -- Mask circle
      love.graphics.stencil(function()
        love.graphics.circle("fill", champ.pos.x, champ.pos.y, champ.size / 2)
      end, "replace", 1)
      love.graphics.setStencilTest("equal", 1)
      -- Draw sprite
      love.graphics.draw(champ.sprite, champ.pos.x, champ.pos.y, 0, champ.size / champ.sprite:getWidth(),
        champ.size / champ.sprite:getHeight(), champ.sprite:getWidth() / 2, champ.sprite:getHeight() / 2)
      -- Reset the mask
      love.graphics.setStencilTest()
    end

    -- Draw health bars
    for _, champ in pairs(champs) do
      -- Red
      love.graphics.setColor(0.8, 0.1, 0.1)
      love.graphics.rectangle("fill", champ.pos.x - champ.size / 2, champ.pos.y + champ.size / 2, champ.size, 10)
      -- Shield
      if champ:has_effect("shield") then
        local amount = 0
        for _, shield in pairs(champ:get_effects("shield")) do
          amount = amount + shield.amount
        end
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.rectangle("fill", champ.pos.x - champ.size / 2, champ.pos.y + champ.size / 2,
          ((champ.health + amount) / champ.max_health) * champ.size, 10)
      end
      -- Green
      love.graphics.setColor(0, 1, 0)
      love.graphics.rectangle("fill", champ.pos.x - champ.size / 2, champ.pos.y + champ.size / 2,
        (champ.health / champ.max_health) * champ.size, 10)
    end
  end
  Camera:detach()
end
