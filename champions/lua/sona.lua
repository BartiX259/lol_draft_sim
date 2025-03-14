local buff_cast = require("abilities.buff")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local shield = require("effects.shield")
local speed = require("effects.speed")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local sona = {}

-- Constructor
function sona.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1892,
    armor = 61.4,
    mr = 45.6,
    ms = 385,
    sprite = 'sona.jpg',
    damage_split = { 0.0, 0.9999999999999999, 0.0 }
  })
  champ.abilities = {
    aa = ranged_aa_cast.new(1.2, 550, 85, { 0.8,0.9,1.0 }),
    q = ranged_cast.new(4.8, 825),
    w = buff_cast.new(6.2, 1000),
    e = buff_cast.new(7.1, 400),
    r = ranged_cast.new(83.33, 1000),
  }

function champ.abilities.q:use(context, cast)
context.spawn( aoe:new(self, { colliders = nil,
size = 400,
color = { 0.4,0.6,0.9,0.9 },
deploy_time = 0.2,
persist_time = 2,
follow = champ,
})
)
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 80,
speed = 1500,
color = { 0.4,0.6,0.9,0.9 },
range = 825,
from = champ.pos,
to = cast.target,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(232, damage.MAGIC):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
context.spawn( aoe:new(self, { colliders = nil,
size = 400,
color = { 0.4,0.9,0.6,0.9 },
deploy_time = 0.2,
persist_time = 2,
follow = champ,
})
)
for _,ally in pairs ( distances.in_range_list ( champ , context.allies , 1000 )) do
ally :heal ( 200 )
ally:effect(shield.new(2.0, 205.0))
end
end

function champ.abilities.e:use(context, cast)
context.spawn( aoe:new(self, { colliders = nil,
size = 400,
color = { 0.8,0.4,0.85,0.9 },
deploy_time = 0.2,
persist_time = 2,
follow = champ,
})
)
for _,ally in pairs ( distances.in_range_list ( champ , context.allies , 400 )) do
ally:effect(speed.new(2.0, 0.25))
end
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 280,
speed = 2400,
color = { 0.8,0.7,0.2 },
range = 1000,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(240, damage.MAGIC):deal(champ, target)
target:effect(stun.new(1.5))
end

function champ.behaviour(ready, context)
champ.range = 825+200
champ:change_movement(movement.PEEL)
end

  return champ
end

return sona