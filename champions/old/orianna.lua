local champion = require("util.champion")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local splash = require("abilities.splash")
local damage = require("util.damage")
local movement = require("util.movement")
local distances = require("util.distances")

local orianna = {}

local Q = {
  CD = 3.5,
  RANGE = 825,
  DAMAGE = 300,
  SPEED = 1200,
  SIZE = 175
}

local W = {
  DAMAGE = 400,
  SIZE = 225
}

local R = {
  CD = 90,
  DAMAGE = 500,
  SIZE = 415,
  PULL_SPEED = 1200
}

-- Constructor
function orianna.new(x, y)
  local champ = champion.new({
    x = x,
    y = y,
    health = 1789.5,
    armor = 66,
    mr = 40,
    ms = 370,
    sprite = "orianna.jpg",
  })

  champ.abilities = {
    q = splash.new(Q.CD, Q.RANGE, Q.SIZE),
    r = ability:new(R.CD)
  }
  champ.abilities.q.w = {}

  -- Behaviour
  function champ.behaviour(ready)
    if ready.q then
      champ.range = Q.RANGE - 50
      champ:change_movement(movement.AGGRESSIVE)
    else
      champ.range = Q.RANGE + 200
      champ:change_movement(movement.PASSIVE)
    end
  end

  function champ.abilities.q:ready(context)
    local cast = self:cast(context)
    if cast == nil then
      return false
    end

    self.proj = missile.new(self, {
      pos = champ.pos,
      dir = cast.dir,
      size = Q.SIZE,
      speed = Q.SPEED,
      range = cast.mag,
      colliders = context.enemies,
      color = { 0.3, 0.5, 0.8 }
    })
    self.proj.next = aoe.new(self.w,
      { size = W.SIZE, persist_time = 2, colliders = context.enemies, color = { 0.3, 0.5, 0.8 } })
    context.spawn(self.proj)

    return true
  end

  function champ.abilities.q:hit(target)
    damage:new(Q.DAMAGE, damage.MAGIC):deal(champ, target)
  end

  function champ.abilities.q.w:hit(target)
    damage:new(W.DAMAGE, damage.MAGIC):deal(champ, target)
    target:effect(require("effects.slow").new(0.5, 0.3))
  end

  function champ.abilities.r:ready(context)
    local orb = champ.abilities.q.proj
    if orb == nil then
      return false
    end

    if distances.in_range(orb, context.enemies, R.SIZE / 2 - 10) >= math.max(math.min(3, #context.enemies - 1), 1) then
      self.proj = aoe.new(self,
        { pos = orb.pos, deploy_time = 0.2, size = R.SIZE, follow = orb, colliders = context.enemies, color = { 0.3, 0.5, 0.8, 0.6 } })
      context.spawn(self.proj)
      return true
    end

    return false
  end

  function champ.abilities.r:hit(target)
    damage:new(R.DAMAGE, damage.MAGIC):deal(champ, target)
    target:effect(require("effects.pull").new(self.proj, R.PULL_SPEED))
  end

  return champ
end

return orianna
