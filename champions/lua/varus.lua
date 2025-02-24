local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")
local missile = require("projectiles.missile")
local ranged = require("abilities.ranged")
local ranged_aa = require("abilities.ranged_aa")
local root = require("effects.root")

local varus = {}

-- Constructor
function varus.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1865,
    armor = 116,
    mr = 85,
    ms = 385,
    sprite = 'varus.jpg',
  })

  champ.abilities = {
    aa = ranged_aa.new(0.74, 675, 241, { 0.7,0.1,0.8 }),
    q = ranged.new(12, 1595),
    r = ranged.new(80, 1370),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 140,
speed = 1900,
color = { 0.7,0.1,0.8 },
range = 1595,
from = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(585, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 240,
speed = 1500,
color = { 0.7,0.1,0.8 },
range = 1370,
from = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(550, damage.MAGIC):deal(champ, target)
target:effect(root.new(2.0))
end

function champ.behaviour(ready, context)
champ.range = 675
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return varus