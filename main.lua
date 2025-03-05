require("util.extensions")
local vec2 = require("util.vec2")
local distances = require("util.distances")
local ui = require("ui.main")
local dump = require("util.dump")
local camera = require("util.camera")
local font = love.graphics.newFont(require("ui.badr").font, 25)

local PLAYING = 0
local BLUE_WIN = 1
local RED_WIN = 2
local DRAFT = 3
local SIM_END = 4
local RANDOM_SIM_END = 5
local GLITCH = 6

function love.load()
  love.window.setMode(1200, 800, {resizable = true})
  -- love.window.maximize()
  Draft = { blue = {}, red = {} }
  GameState = DRAFT
end

function NewGame()
  GameState = PLAYING
  Camera = camera(0, 0)
  Camera:zoom(0.3)
  ui.clear()
  BlueTeam = {}
  RedTeam = {}
  local x = -600
  for _, champ in pairs(Draft.blue) do
    local champ = require("champions.lua."..champ).new(x, 1300)
    for _, ability in pairs(champ.abilities) do
      if ability.start then
        ability:start()
      end
    end
    table.insert(BlueTeam, champ)
    x = x + 200
  end
  x = -600
  for _, champ in pairs(Draft.red) do
    local champ = require("champions.lua."..champ).new(x, -1300)
    for _, ability in pairs(champ.abilities) do
      if ability.start then
        ability:start()
      end
    end
    table.insert(RedTeam, champ)
    x = x + 200
  end
  BlueProjectiles = {}
  RedProjectiles = {}
  Capture = 0
  CaptureRadius = 300
  CaptureSpeed = 0.05
  Tick = 0
  Delays = {}
  BlueTeamAll = table.shallow_copy(BlueTeam)
  RedTeamAll = table.shallow_copy(RedTeam)
end

function RandomDraft()
  Draft = {blue = {}, red = {}}
  
  -- Shuffle function to randomize the pool
  local function shuffleTable(tbl)
    for i = #tbl, 2, -1 do
      local j = math.random(i)
      tbl[i], tbl[j] = tbl[j], tbl[i]
    end
  end
  
  -- Load available champions from the champions/lua directory
  local function loadChampionPool()
    local champions = {}
    local files = love.filesystem.getDirectoryItems("champions/lua")
    for _, file in ipairs(files) do
      if file:match("%.lua$") then
        local champName = file:gsub("%.lua$", "")
        table.insert(champions, champName)
      end
    end
    return champions
  end
  
  local championPool = loadChampionPool()
  
  -- Select random champions for both teams
  shuffleTable(championPool)
  for i = 1, math.min(5, #championPool) do
    table.insert(Draft.blue, championPool[i])
  end
  
  shuffleTable(championPool)
  for i = 1, math.min(5, #championPool) do
    table.insert(Draft.red, championPool[i])
  end
end

ui.new_game = function ()
  SimInfo = nil
  RandomSimInfo = nil
  NewGame()
end
ui.new_sim = function()
  local game_count = 100
  ---@class SimInfo
  SimInfo = { games = game_count, games_left = game_count, blue_wins = 0, red_wins = 0, blue = {}, red = {} }
  RandomSimInfo = nil
  NewGame()
end
ui.random_sim = function()
  local game_count = 1500
  SimInfo = nil
  ---@class RandomSimInfo
  RandomSimInfo = { games = game_count, games_left = game_count, champs = {} }
  NewGame()
end
ui.set_draft = function(draft)
  Draft = draft
end
ui.draft_mode = function ()
  GameState = DRAFT
end

function SpawnBlue(projectile)
  table.insert(BlueProjectiles, projectile)
end

function SpawnRed(projectile)
  table.insert(RedProjectiles, projectile)
end

function DespawnBlue(projectile)
  for id, value in pairs(BlueProjectiles) do
    if value == projectile then
      table.remove(BlueProjectiles, id)
    end
  end
end

function DespawnRed(projectile)
  for id, value in pairs(RedProjectiles) do
    if value == projectile then
      table.remove(RedProjectiles, id)
    end
  end
end

function Delay(time, func)
    table.insert(Delays, { time = time, func = func })
end

local avg_tps = 0

function RandomSimResult(res)
  local function add_res(champ, res)
    if RandomSimInfo.champs[champ.name] == nil then
      RandomSimInfo.champs[champ.name] = {wins = 0, losses = 0, sprite = champ.sprite}
    end
    RandomSimInfo.champs[champ.name][res] = RandomSimInfo.champs[champ.name][res] + 1
  end
  for _, champ in pairs(res == BLUE_WIN and BlueTeamAll or RedTeamAll) do
    add_res(champ, "wins")
  end
  for _, champ in pairs(res == BLUE_WIN and RedTeamAll or BlueTeamAll) do
    add_res(champ, "losses")
  end
  RandomSimInfo.games_left = RandomSimInfo.games_left - 1
  if RandomSimInfo.games_left == 0 then
    GameState = RANDOM_SIM_END
    for _, champ in pairs(RandomSimInfo.champs) do
      champ.win_rate = champ.wins / (champ.wins + champ.losses)
    end
    print("Average TPS: " .. string.format("%.0f", avg_tps))
    --dump.dump(RandomSimInfo)
  else
    RandomDraft()
    NewGame()
  end
end

function SimResult(res)
  if res == BLUE_WIN then
      SimInfo.blue_wins = SimInfo.blue_wins + 1
  elseif res == RED_WIN then
      SimInfo.red_wins = SimInfo.red_wins + 1
  end
  for _, pair in ipairs({ { BlueTeamAll, "blue" }, { RedTeamAll, "red" } }) do
    for id, champ in pairs(pair[1]) do
      local function update_val(key, value)
        local ptr = SimInfo[pair[2]]
        if ptr[id] == nil then
          ptr[id] = {}
        end
        ptr = ptr[id]
        if ptr[key] == nil then
            ptr[key] = 0
        end
        ptr[key] = ptr[key] + value
      end
      update_val("damage_dealt", champ.damage_dealt)
    end
  end
  SimInfo.games_left = SimInfo.games_left - 1
  if SimInfo.games_left == 0 then
    GameState = SIM_END
    for _, pair in ipairs({ { BlueTeamAll, "blue" }, { RedTeamAll, "red" } }) do
      for id, champ in pairs(pair[1]) do
        SimInfo[pair[2]][id].sprite = champ.sprite
        SimInfo[pair[2]][id].name = champ.name
      end
    end
  else
    NewGame()
  end
end

local tick_rate = 0.02 -- 50 logic updates per second
local tick_count = 0 -- Tracks ticks per second
local last_tps_update = love.timer.getTime() -- Time tracker for TPS
local tps = 0
local tps_samples = 0

function love.update(dt)
  if (SimInfo or RandomSimInfo) and GameState == PLAYING then
    local start_time = love.timer.getTime()

    -- Run as many ticks as possible within the frame time budget
    while love.timer.getTime() - start_time < dt * 0.9 do
      for _ = 1, 20 do
        GameTick(tick_rate)
        tick_count = tick_count + 1
      end
    end

    -- Calculate and log TPS every second
    local now = love.timer.getTime()
    if now - last_tps_update >= 1 then
      tps = tick_count / (now - last_tps_update)
      tps_samples = tps_samples + 1
      avg_tps = avg_tps + (tps - avg_tps) / tps_samples
      tick_count = 0 -- Reset counter
      last_tps_update = now
    end
  else
    GameTick(dt) -- Run normal game updates
  end
end



function GameTick(dt)
  if GameState == GLITCH then
    return
  end

  if GameState ~= PLAYING then
      ui.update()
      return
  end

  if Capture >= 1 or rawequal(next(RedTeam), nil) then
      if SimInfo then
        SimResult(BLUE_WIN)
      elseif RandomSimInfo then
        RandomSimResult(BLUE_WIN)
      else
        GameState = BLUE_WIN
        ui.update()
      end
      return
  elseif Capture <= -1 or rawequal(next(BlueTeam), nil) then
      if SimInfo then
        SimResult(RED_WIN)
      elseif RandomSimInfo then
        RandomSimResult(RED_WIN)
      else
        GameState = RED_WIN
        ui.update()
      end
      return
  end
  
  Tick = Tick + 1

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
        despawn = is_blue and DespawnBlue or DespawnRed,
        delay = Delay,
        tick = tostring(Tick),
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
        if effect.tags["silence"] then
          can_cast = false
        end
        if effect.tags["root"] then
          move_mult = 0
        end
        if effect.tags["slow"] or effect.tags["speed"] then
          move_mult = move_mult * effect.amount
        end
        if effect:tick(context) then
          table.remove(champ.effects, id)
          if effect.on_finish_func ~= nil then
            effect.on_finish_func()
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
            if cast and ability.precast then
              cast = ability:precast(context, cast)
            end
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
      if projectile.despawn or projectile:update(dt) then
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
    Capture = Capture + dir * math.min(math.abs(Capture), CaptureSpeed * dt / 2)
  else
    local dir = objective_count / (1 + math.abs(objective_count) / 4) * math.min(5 / (#BlueTeam + #RedTeam), 1.5)
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
    ui.game_end(ui.BLUE, BlueTeamAll, RedTeamAll)
    return
  end
  if GameState == RED_WIN then
    ui.game_end(ui.RED, BlueTeamAll, RedTeamAll)
    return
  end
  if GameState == SIM_END then
    ui.sim_end(SimInfo)
    return
  end
  if GameState == RANDOM_SIM_END then
    ui.random_sim_end(RandomSimInfo)
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
    for _, team in ipairs({ { BlueTeam, { 0.4, 0.4, 1 } }, { RedTeam, { 1, 0.4, 0.4 } } }) do
        local champs, color = team[1], team[2]

        -- Draw champions
        love.graphics.setColor(color)
        for _, champ in pairs(champs) do
            love.graphics.setColor(color)
            if champ:has_effect("root") then
                love.graphics.setColor({ 1000, 1000, 1000 })
            end
            -- Move direction
            love.graphics.line(champ.pos.x, champ.pos.y, champ.pos.x + champ.move_dir.x, champ.pos.y + champ.move_dir.y)
            -- Outline
            love.graphics.circle("fill", champ.pos.x, champ.pos.y, champ.size / 2 + 5)
            -- Circle mask
            love.graphics.stencil(function()
                love.graphics.circle("fill", champ.pos.x, champ.pos.y, champ.size / 2)
            end, "replace", 1)
            love.graphics.setStencilTest("equal", 1)
            -- Draw sprite
            love.graphics.setColor({ 1, 1, 1 })
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
            love.graphics.setColor(0.1, 0.9, 0.1)
            love.graphics.rectangle("fill", champ.pos.x - champ.size / 2, champ.pos.y + champ.size / 2,
                (champ.health / champ.max_health) * champ.size, 10)
        end
    end
  Camera:detach()
  local info = SimInfo or RandomSimInfo
  if info then
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    love.graphics.print("Games: " .. tostring(info.games - info.games_left) .. "/" .. tostring(info.games), 0, 0)
    love.graphics.print("TPS: " .. string.format("%.0f", tps), 0, 25)
  end
end
