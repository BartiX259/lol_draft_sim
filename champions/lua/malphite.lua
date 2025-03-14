local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local slow = require("effects.slow")
local speed = require("effects.speed")
local unstoppable = require("effects.unstoppable")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local malphite = {}

-- Constructor
function malphite.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2613,
    armor = 201.4,
    mr = 112.6,
    ms = 385,
    sprite = 'malphite.jpg',
    damage_split = { 0.0, 1.0, 0.0 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(1.36, 125, 110),
    q = ranged_cast.new(6.1, 625),
    e = splash_cast.new(6.8, 400, 400),
    r = splash_cast.new(105, 1000, 300),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 150,
speed = 1600,
color = { 0.6,0.7,0.4 },
range = 625,
from = champ.pos,
to = cast.target,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(370, damage.MAGIC):deal(champ, target)
target:effect(slow.new(3.0, 0.4))
champ:effect(speed.new(3.0, 0.4))
end

function champ.abilities.e:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 400,
color = { 0.6,0.7,0.4 },
at = champ,
deploy_time = 0.24,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(180, damage.MAGIC):deal(champ, target)
target:effect(slow.new(3.0, 0.5))
end

function champ.abilities.r:use(context, cast)
local deploy_time = cast.mag / 2000
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.6,0.7,0.4 },
deploy_time = deploy_time,
at = cast.pos,
})
champ:effect(unstoppable.new(1.0))
champ:effect(dash.new(2000, cast.pos))
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(430, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.5))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 625
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 625+100
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return malphite