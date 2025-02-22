local champion = require("util.champion")
local missile = require("projectiles.missile")
local targeted = require("projectiles.targeted")
local ability = require("util.ability")
local ranged = require("abilities.ranged")
local damage = require("util.damage")
local movement = require("util.movement")
local vec2 = require("util.vec2")


local nautilus = {}

local AA = {
  DAMAGE = 150,
  STUN_DURATION = 1
}

local Q = {
  CD = 8.7,
  DAMAGE = 100,
  RANGE = 1100,
  SPEED = 2000,
  SIZE = 180,
  PULL_SPEED = 1300,
  PULL_DISTANCE_FRACTION = 0.5,
}

local R = {
  CD = 70,
  DAMAGE = 250,
  RANGE = 850,
  AIRBORNE_DURATION = 1,
  SIZE = 150,
  SPEED = 500
}

function nautilus.new(x, y)
  local champ = champion.new({
    x = x,
    y = y,
    health = 2100,
    armor = 218,
    mr = 103,
    ms = 370,
    sprite = "nautilus.jpg",
  })

  champ.abilities = {
    q = ranged.new(Q.CD, Q.RANGE),
    r = ranged.new(R.CD, R.RANGE),
  }

  -- Behaviour
  function champ.behaviour(ready)
    if ready.q then
      champ.range = Q.RANGE - 50
      champ:change_movement(movement.AGGRESSIVE)
    else
      champ.range = Q.RANGE + 200
      champ:change_movement(movement.PEEL)
    end
  end

  -- Dredge Line (Q)
  function champ.abilities.q:ready(context)
    local cast = self:cast(context)
    if cast == nil then
      return false
    end

    -- Fire the hook
    self.proj = missile.new(self,
      {
        pos = context.champ.pos,
        dir = cast.dir,
        size = Q.SIZE,
        speed = Q.SPEED,
        range = Q.RANGE,
        stop_on_hit = true,
        colliders = context.enemies,
        color = { 0.2, 0.7, 0.7 }
      })
    context.spawn(self.proj)
    return true
  end

  function champ.abilities.q:hit(target)
    damage:new(Q.DAMAGE, damage.MAGIC):deal(champ, target)

    -- Calculate pull distance and direction
    local distance = (target.pos - champ.pos):mag()
    local pull_distance = distance * Q.PULL_DISTANCE_FRACTION
    local pull_direction = (target.pos - champ.pos):normalize()

    -- Pull target towards Nautilus, then auto attack
    target:effect(require("effects.pull").new(target.pos - pull_direction * (distance - pull_distance), Q.PULL_SPEED)
    :on_finish(function()
      damage:new(AA.DAMAGE, damage.PHYSICAL):deal(champ, target)
      target:effect(require("effects.stun").new(AA.STUN_DURATION))
    end))
    -- Pull Nautilus towards target
    champ:effect(require("effects.pull").new(champ.pos + pull_direction * pull_distance, Q.PULL_SPEED))
  end

  -- Depth Charge (R)
  function champ.abilities.r:ready(context)
    local cast = self:cast(context)
    if cast == nil then
      return false
    end

    self.proj = missile.new(self,
      { pos = context.champ.pos, target = cast.target, size = R.SIZE, speed = R.SPEED, color = { 0.2, 0.7, 0.7 } })
    context.spawn(self.proj)

    return true
  end

  function champ.abilities.r:hit(target)
    damage:new(R.DAMAGE, damage.MAGIC):deal(champ, target)
    target:effect(require("effects.airborne").new(R.AIRBORNE_DURATION))
  end

  return champ
end

return nautilus
