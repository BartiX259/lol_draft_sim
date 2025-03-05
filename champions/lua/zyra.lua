local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local airborne = require("effects.airborne")
local root = require("effects.root")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local zyra = {}

-- Constructor
function zyra.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1940,
    armor = 79.4,
    mr = 45.6,
    ms = 385,
    sprite = 'zyra.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.47, 575, 94, { 0.4,0.8,0.2 }),
    q = splash_cast.new(4.8, 800, 200),
    e = ranged_cast.new(8.15, 1100),
    r = splash_cast.new(66.67, 700, 500),
  }

function champ.abilities.q:use(context, cast)
for _,dir in pairs ( cast.dir :perp ( 3 )) do
local at = cast.pos + dir * 200
context.spawn( aoe:new(self, { colliders = context.enemies,
size = 200,
color = { 0.4,0.8,0.2 },
deploy_time = 0.625,
at = at,
})
)
end
end

function champ.abilities.q:hit(target)
damage:new(324, damage.MAGIC):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 140,
speed = 1150,
color = { 0.4,0.8,0.2 },
range = 1100,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(296, damage.MAGIC):deal(champ, target)
target:effect(root.new(2.0))
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 500,
color = { 0.4,0.8,0.2 },
deploy_time = 1,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(380, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.0))
end

function champ.behaviour(ready, context)
if ready.e then
champ.range = 1100
champ:change_movement(movement.AGGRESSIVE)
elseif ready.q then
champ.range = 800
champ:change_movement(movement.PASSIVE)
else
champ.range = 800+150
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return zyra