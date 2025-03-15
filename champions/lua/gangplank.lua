local big_cast = require("abilities.big")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local gangplank = {}

-- Constructor
function gangplank.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2138,
    armor = 87.4,
    mr = 56.6,
    ms = 390,
    sprite = 'gangplank.jpg',
    damage_split = { 0.9978370388137957, 0.0021629611862043416, 0.0 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(1.3, 175, 238.4),
    q = ranged_cast.new(3.7, 725),
    e = splash_cast.new(6.3, 750, 250),
    r = big_cast.new(142.86, 1000, 580),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 100,
speed = 2600,
color = { 0.7,0.5,0.3 },
range = 725,
from = champ.pos,
to = cast.target,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(460.5, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 250,
color = { 0.7,0.5,0.3 },
deploy_time = 0.2,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(640, damage.PHYSICAL):deal(champ, target)
target:effect(slow.new(2.0, 0.8))
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 580,
color = { 0.7,0.5,0.3 },
persist_time = 8,
tick = 2,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(70, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.0, 0.3))
end

function champ.behaviour(ready, context)
champ.range = 725+100
champ:change_movement(movement.PEEL)
end

  return champ
end

return gangplank