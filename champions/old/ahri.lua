local champion = require("util.champion")
local ranged = require("abilities.ranged")
local splash = require("abilities.splash")
local dash = require("abilities.dash")
local damage = require("util.damage")
local missile = require("projectiles.missile")
local vec2 = require("util.vec2")
local movement = require("util.movement")

local ahri = {}

local Q = {
  CD = 5,
  DAMAGE = 280,
  RANGE = 880,
  SPEED = 1750,
  SIZE = 200,
}

local E = {
  CD = 8,
  DAMAGE = 270,
  RANGE = 975,
  SPEED = 1550,
  SIZE = 120,
  CHARM_DURATION = 1.5,
  CHARM_SPEED = 100
}


local R = {
  CD = 8, -- Time window to use all charges
  DASH_RANGE = 500,
  DASH_SPEED = 1300,
}

function ahri.new(x, y)
  local champ = champion.new({
    x = x,
    y = y,
    health = 1728.8,
    armor = 72.5,
    mr = 44.25,
    ms = 375,
    sprite = "ahri.jpg",
  })

  champ.abilities = {
    q = splash.new(Q.CD, Q.RANGE, Q.SIZE),
    e = ranged.new(E.CD, E.RANGE),
    r = dash.new(R.CD, R.DASH_RANGE, E.RANGE)
  }

  -- Behaviour
  function champ.behaviour(ready)
    champ.range = E.RANGE
    champ:change_movement(movement.PASSIVE)
    if ready.q then
      champ.range = Q.RANGE
    end
    if ready.e then
      champ:change_movement(movement.AGGRESSIVE)
    end
    if not (ready.q or ready.e) then
      champ.range = Q.RANGE + 500
      champ:change_movement(movement.PEEL)
    end
  end

  -- Charm (E) ability
  function champ.abilities.e:ready(context)
    local cast = self:cast(context)
    if cast == nil then
      return false
    end
    -- Fire E
    self.proj = missile.new(self,
      {
        pos = context.champ.pos,
        dir = cast.dir,
        size = E.SIZE,
        speed = E.SPEED,
        range = E.RANGE,
        stop_on_hit = true,
        colliders = context.enemies,
        color = { 1, 0.2, 0.8 }
      })

    context.spawn(self.proj)
    return true
  end

  function champ.abilities.e:hit(target)
    damage:new(E.DAMAGE, damage.MAGIC):deal(champ, target)
    target:effect(require("effects.charm").new(
      E.CHARM_DURATION,
      E.CHARM_SPEED,
      champ
    ))
  end

  -- Q ability
  function champ.abilities.q:ready(context)
    local cast = self:cast(context)
    if cast == nil then
      return false
    end

    -- Fire Q
    local proj = missile.new(self,
      {
        pos = context.champ.pos,
        dir = cast.dir,
        size = Q.SIZE,
        speed = Q.SPEED,
        range = Q.RANGE,
        colliders = context.enemies,
        color = { 0.4, 0.5, 0.9 }
      })
    proj.next = missile.new(self,
      { target = champ, size = Q.SIZE, speed = Q.SPEED, range = Q.RANGE, colliders = context.enemies, color = { 0.4, 0.5, 0.9 } })
    context.spawn(proj)
    return true
  end

  function champ.abilities.q:hit(target)
    damage:new(Q.DAMAGE, damage.MAGIC):deal(champ, target)
  end

  -- Ultimate (Spirit Rush)
  function champ.abilities.r:ready(context)
    local cast = self:cast(context)
    if cast == nil then
      return false
    end

    context.champ:effect(require("effects.pull").new(
      cast.pos,
      R.DASH_SPEED
    ))

    return true
  end

  return champ
end

return ahri
