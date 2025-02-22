local champion = require("util.champion")
local aoe = require("projectiles.aoe")
local ability = require("util.ability")
local aa = require("abilities.melee_aa")
local splash = require("abilities.splash")
local damage = require("util.damage")
local movement = require("util.movement")
local vec2 = require("util.vec2")
local distances = require("util.distances")

local wukong = {}

local AA = {
  CD = 1.2,
  DAMAGE = 195,
  RANGE = 175
}

local E = {
  CD = 7,
  DAMAGE = 140,
  RANGE = 600,
  SPEED = 1500,
  AOE_SIZE = 375,
  AOE_DURATION = 0.2
}

local R = {
  CD = 72,
  DAMAGE = 140,
  SIZE = 400,
  DURATION_TICKS = 8,
  TICK_TIME = 0.25,
  AIRBORNE_DURATION = 0.5
}

-- Constructor
function wukong.new(x, y)
  local champ = champion.new({
    x = x,
    y = y,
    health = 2000,
    armor = 180,
    mr = 50.45,
    ms = 385,
    sprite = "wukong.jpg",
  })

  champ.abilities = {
    aa = aa.new(AA.CD, AA.RANGE, AA.DAMAGE),
    e = splash.new(E.CD, E.RANGE, R.SIZE),
    r = ability:new(R.CD)
  }
  champ.spinning = false

  -- Behaviour
  function champ.behaviour(ready, context)
    champ.target = nil
    if champ.spinning or context.closest_enemy.pos:distance(champ.pos) < AA.RANGE + 100 then
      champ.range = AA.RANGE
      champ.target = context.closest_enemy
    elseif ready.e then
      champ.range = AA.RANGE
      champ:change_movement(movement.AGGRESSIVE)
    else
      champ.range = E.RANGE + 400
      champ:change_movement(movement.PEEL)
    end
  end

  function champ.abilities.e:ready(context)
    local cast = self:cast(context)
    if cast == nil then
      return false
    end

    if cast.mag > E.RANGE then
      return false -- Too far to dash
    end

    -- Dash to target
    champ:effect(require("effects.pull").new(cast.target, E.SPEED))
    self.proj = aoe.new(self,
      {
        pos = champ.pos,
        deploy_time = 0.5,
        size = E.AOE_SIZE,
        follow = champ,
        persist_time = E.AOE_DURATION,
        colliders = context.enemies,
        color = { 0.8, 0.8, 0.8, 0.5 }
      })

    context.spawn(self.proj)
    return true
  end

  function champ.abilities.e:hit(target)
    damage:new(E.DAMAGE, damage.MAGIC):deal(champ, target)
  end

  champ.abilities.r.first = {}

  function champ.abilities.r:ready(context)
    if distances.in_range(champ, context.enemies, R.SIZE / 2) >= math.max(math.min(2, #context.enemies - 2), 1) then --ult range check
      champ.spinning = true
      self.proj = aoe.new(self.first,
        {
          pos = champ.pos,
          deploy_time = 0.2,
          size = R.SIZE,
          persist_time = R.TICK_TIME,
          follow = champ,
          hard_follow = true,
          colliders = context.enemies,
          color = { 0.9, 0.9, 0.9, 0.9 }
        })
      local proj = self.proj
      for _ = 1, R.DURATION_TICKS, 1 do
        proj.next = aoe.new(self,
          {
            size = R.SIZE,
            persist_time = R.TICK_TIME,
            follow = champ,
            hard_follow = true,
            colliders = context.enemies,
            color = { 0.9, 0.9, 0.9, 0.9 }
          })
        proj = proj.next
      end
      context.spawn(self.proj)
      context.delay(R.DURATION_TICKS * R.TICK_TIME, function()
        champ.spinning = false
      end)
      return true
    end
    return false
  end

  function champ.abilities.r.first:hit(target)
    damage:new(R.DAMAGE, damage.PHYSICAL):deal(champ, target)
    target:effect(require("effects.airborne").new(R.AIRBORNE_DURATION))
  end

  function champ.abilities.r:hit(target)
    damage:new(R.DAMAGE, damage.PHYSICAL):deal(champ, target)
  end

  return champ
end

return wukong
