local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local shield = require("effects.shield")
local slow = require("effects.slow")
local speed = require("effects.speed")
local stun = require("effects.stun")
local unstoppable = require("effects.unstoppable")
local aoe = require("projectiles.aoe")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local udyr = {}

-- Constructor
function udyr.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2418,
    armor = 80.4,
    mr = 66.7,
    ms = 395,
    sprite = 'udyr.jpg',
    damage_split = { 0.0, 1.0, 0.0 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(1.3, 125, 190),
    w = ranged_cast.new(5.7, 3000),
    e = ranged_cast.new(5.7, 400),
    e_stun = ranged_cast.new(0, 125),
    r = ranged_cast.new(5.7, 185),
  }
champ.abilities.e_stun:join(champ.abilities.e)

function champ.abilities.w:use(context, cast)
champ:effect(shield.new(4.0, 198.0))
champ :heal ( 80 )
end

function champ.abilities.e:use(context, cast)
self.active = true
context.delay(4, function() self.active = false
end)
champ:effect(speed.new(4.0, 0.65))
champ:effect(unstoppable.new(3.0))
end

function champ.abilities.e_stun:use(context, cast)
damage:new(190, damage.MAGIC):deal(champ, cast.target)
cast.target:effect(stun.new(1.0))
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 370,
color = { 0.3,0.7,0.8,0.9 },
persist_time = 6,
tick = 0.5,
follow = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(80.5, damage.MAGIC):deal(champ, target)
target:effect(slow.new(0.5, 0.3))
end

function champ.behaviour(ready, context)
if context.closest_dist < 125 + 50 or champ.abilities.e.active then
champ.range = 125
champ.target = context.closest_enemy
else
champ.range = 600
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return udyr