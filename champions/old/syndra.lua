local champion = require("util.champion")
local missile = require("projectiles.missile")
local aoe = require("projectiles.aoe")
local ability = require("util.ability")
local splash = require("abilities.splash")
local damage = require("util.damage")
local movement = require("util.movement")
local distances = require("util.distances")

local syndra = {}

local Q = {
  CD = 4.5,
  DAMAGE = 350,
  RANGE = 800,
  SIZE = 210,
  PUSH_DISTANCE = 300, --How far the sphere is pushed
  DELAY = 0.4,
}

local E = {
  DAMAGE = 175,
  PUSH_DISTANCE = 400, --How far back they are pushed
  PUSH_SPEED = 2000,   --the speed
  STUN_DURATION = 1,
  AOE1_SIZE = 280,     --The first short range AOE
  AOE1_OFFSET = 250,   --Distance
  AOE2_SIZE = 430,     --Long range
  AOE2_OFFSET = 600,   --Distance
  AOE_DELAY = 0.2      --delay of push
}

local R = {
  CD = 84,
  DAMAGE = 214,
  PROJECTILE_SPEED = 1500,
  PROJECTILE_SIZE = 100, --radius
  PROJECTILES = 5,       --num projectiles spawned
  PROJECTILES_INTERVAL = 0.1,
  RANGE = 675            --ult range
}

-- Constructor
function syndra.new(x, y)
  local champ = champion.new({
    x = x,
    y = y,
    health = 1701.8,
    armor = 75.4,
    mr = 44.25,
    ms = 375,
    sprite = "syndra.jpg",
  })

  champ.abilities = {
    qe = splash.new(Q.CD, Q.RANGE, Q.SIZE),
    r = ability:new(R.CD)
  }
  champ.abilities.qe.e = {}
  champ.abilities.qe.q_push = {}

  -- Behaviour
  function champ.behaviour(ready, context)
    if ready.r and context.closest_enemy.health <= R.DAMAGE * R.PROJECTILES then
      champ.range = R.RANGE - 50
      champ:change_movement(movement.AGGRESSIVE)
    elseif ready.qe then
      champ.range = Q.RANGE - 50
      champ:change_movement(movement.AGGRESSIVE)
    else
      champ.range = Q.RANGE + 200
      champ:change_movement(movement.PASSIVE)
    end
  end

  function champ.abilities.qe:ready(context)
    local cast = self:cast(context)
    if cast == nil then
      return false
    end

    -- Q: Dark sphere
    self.proj = aoe.new(self,
      { pos = cast.pos, deploy_time = Q.DELAY, size = Q.SIZE, colliders = context.enemies, color = { 0.8, 0.5, 0.8 }, persist_time = 0 })
    self.proj.next = missile.new(self.q_push,
      {
        pos = cast.pos,
        dir = cast.dir,
        size = Q.SIZE,
        speed = E.PUSH_SPEED,
        range = Q.PUSH_DISTANCE,
        colliders = context.enemies,
        color = { 0.8, 0.5, 0.8 }
      })
    self.q_push.origin = cast.pos
    context.spawn(self.proj)

    -- E: Scatter the Weak (push forward from sphere)
    local e1 = aoe.new(self.e,
      {
        pos = context.champ.pos + cast.dir * E.AOE1_OFFSET,
        deploy_time = E.AOE_DELAY,
        size = E.AOE1_SIZE,
        persist_time = 0.2,
        colliders = context.enemies,
        color = { 0.8, 0.5, 0.8, 0.5 }
      })
    local e2 = aoe.new(self.e,
      {
        pos = context.champ.pos + cast.dir * E.AOE2_OFFSET,
        deploy_time = E.AOE_DELAY,
        size = E.AOE2_SIZE,
        persist_time = 0.2,
        colliders = context.enemies,
        color = { 0.8, 0.5, 0.8, 0.5 }
      })
    self.e.proj = self.proj
    self.e.origin = context.champ.pos

    context.spawn(e1)
    context.spawn(e2)
    return true
  end

  function champ.abilities.qe:hit(target)
    damage:new(Q.DAMAGE, damage.MAGIC):deal(champ, target)
  end

  function champ.abilities.qe.e:hit(target)
    damage:new(E.DAMAGE, damage.MAGIC):deal(champ, target)
    local dir = target.pos - self.origin
    local dist = E.PUSH_DISTANCE + dir:mag()
    target:effect(require("effects.pull").new(self.origin + dir:normalize() * dist, E.PUSH_SPEED))
  end

  function champ.abilities.qe.q_push:hit(target)
    damage:new(E.DAMAGE, damage.MAGIC):deal(champ, target)
    local dist = Q.PUSH_DISTANCE
    local dir = target.pos - self.origin
    target:effect(require("effects.pull").new(self.origin + dir:normalize() * dist, E.PUSH_SPEED))
    target:effect(require("effects.stun").new(E.STUN_DURATION))
  end

  function champ.abilities.r:ready(context)
    if distances.in_range(context.champ, context.enemies, R.RANGE) >= 1 then -- Check if at least one enemy is in range.
      local target = context.closest_enemy
      if target ~= nil then
        if target.health <= R.DAMAGE * R.PROJECTILES then                                    -- Execute threshold (simplified).
          for i = 0, (R.PROJECTILES - 1) * R.PROJECTILES_INTERVAL, R.PROJECTILES_INTERVAL do --correct timing
            local proj = missile.new(self,
              {
                pos = context.champ.pos,
                target = context.closest_enemy,
                size = R.PROJECTILE_SIZE,
                speed = R.PROJECTILE_SPEED,
                color = { 0.5, 0.1, 0.5 }
              })
            context.delay(i, function() context.spawn(proj) end)
          end
          return true
        end
      end
    end

    return false
  end

  function champ.abilities.r:hit(target)
    damage:new(R.DAMAGE, damage.MAGIC):deal(champ, target)
  end

  return champ
end

return syndra
