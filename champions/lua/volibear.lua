local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local dash = require("effects.dash")
local slow = require("effects.slow")
local speed = require("effects.speed")
local stun = require("effects.stun")
local unstoppable = require("effects.unstoppable")
local aoe = require("projectiles.aoe")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local volibear = {}

-- Constructor
function volibear.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2615,
    armor = 118,
    mr = 66.6,
    ms = 385,
    sprite = 'volibear.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.13, 150, 182),
    q = ranged_cast.new(9.55, 500),
    q_hit = ranged_cast.new(0, 175),
    w = ranged_cast.new(4.9, 350),
    r = splash_cast.new(129, 700, 550),
  }
champ.abilities.q_hit:join(champ.abilities.q)

function champ.abilities.q:use(context, cast)
self.active = true
champ:effect(speed.new(4.0, 0.56):on_finish(function() self.active = false
end))
end

function champ.abilities.q_hit:use(context, cast)
damage:new(212, damage.PHYSICAL):deal(champ, cast.target)
cast.target:effect(stun.new(1.0))
end

function champ.abilities.w:use(context, cast)
damage:new(351, damage.PHYSICAL):deal(champ, cast.target)
champ :heal ( 0.16 * ( champ.max_health - champ.health ))
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 550,
color = { 0.7,0.8,1.0 },
deploy_time = 1.0,
at = cast.pos,
})
local speed = cast.mag / 1.0
champ:effect(dash.new(speed, cast.pos))
local channel = 1.0 * 2
champ:effect(unstoppable.new(1.0))
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(400, damage.PHYSICAL):deal(champ, target)
target:effect(slow.new(1.0, 0.5))
end

function champ.behaviour(ready, context)
if context.closest_dist < 150 + 50 or champ.abilities.q.active then
champ.range = 150
champ.target = context.closest_enemy
else
champ.range = 500+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return volibear