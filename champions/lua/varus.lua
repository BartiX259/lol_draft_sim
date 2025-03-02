local important_cast = require("abilities.important")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local root = require("effects.root")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local varus = {}

-- Constructor
function varus.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1860,
    armor = 67.2,
    mr = 45.6,
    ms = 375,
    sprite = 'varus.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(0.745, 575, 190, { 0.7,0.1,0.8 }),
    q = ranged_cast.new(5.9, 1595),
    r = important_cast.new(72.72, 1370),
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
damage:new(555, damage.PHYSICAL):deal(champ, target)
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
damage:new(250, damage.MAGIC):deal(champ, target)
target:effect(root.new(2.0))
end

function champ.behaviour(ready, context)
champ.range = 575
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return varus