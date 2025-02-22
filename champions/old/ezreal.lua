local champion = require("util.champion")
local missile = require("projectiles.missile")
local ranged = require("abilities.ranged")
local dash = require("abilities.dash")
local damage = require("util.damage")
local movement = require("util.movement")
local vec2 = require("util.vec2")

local ezreal = {}

local Q = {
  CD = 2.9,
  DAMAGE = 351,
  RANGE = 1200,
  SPEED = 2000,
  SIZE = 120,
}
local E = {
  CD = 8.4,
  RANGE = 475,
}

function ezreal.new(x, y)
  local champ = champion.new({
    x = x,
    y = y,
    health = 1716.9,
    armor = 75.5,
    mr = 44.25,
    ms = 375,
    sprite = "ezreal.jpg",
  })

  champ.abilities = {
    q = ranged.new(Q.CD, Q.RANGE),
    e = dash.new(E.CD, E.RANGE, Q.RANGE)
  }

  -- Behaviour
  function champ.behaviour(ready)
    champ.range = Q.RANGE - 50
    champ:change_movement(movement.PASSIVE)
    if ready.e then
      champ:change_movement(movement.AGGRESSIVE)
    end

    if not ready.q then
      champ.range = Q.RANGE + 200
      champ:change_movement(movement.PEEL)
    end
  end

  -- Mystic Shot
  function champ.abilities.q:ready(context)
    local cast = self:cast(context)
    if cast == nil then
      return false
    end

    self.proj = missile.new(self,
      {
        pos = context.champ.pos,
        dir = cast.dir,
        size = Q.SIZE,
        speed = Q.SPEED,
        range = Q.RANGE,
        stop_on_hit = true,
        colliders = context.enemies,
        color = { 0.8, 0.8, 0.2 }
      })
    context.spawn(self.proj)
    return true
  end

  function champ.abilities.q:hit(target)
    for _, ability in pairs(champ.abilities) do
      ability.timer = ability.timer - 1.5
    end
    damage:new(Q.DAMAGE, damage.PHYSICAL):deal(champ, target)
  end

  function champ.abilities.e:ready(context)
    local cast = self:cast(context)
    if cast == nil then
      return false
    end

    require("util.dump").dump(cast.pos)
    context.champ.pos = cast.pos
    return true
  end

  return champ
end

return ezreal
