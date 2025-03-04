local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local slow = require("effects.slow")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local xerath = {}

-- Constructor
function xerath.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1868,
    armor = 78.4,
    mr = 45.6,
    ms = 340,
    sprite = 'xerath.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.3, 525, 81, { 0.2,0.4,0.9 }),
    q = ranged_cast.new(5.5, 1450),
    w = splash_cast.new(9.1, 1000, 275),
    e = ranged_cast.new(10.0, 1125),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 140,
speed = 2800,
color = { 0.2,0.4,0.9 },
range = 1450,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(400, damage.MAGIC):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 275,
color = { 0.2,0.4,0.9 },
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
damage:new(330, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.5, 0.8))
end

function champ.abilities.e:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 1400,
color = { 0.2,0.4,0.9 },
range = 1125,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(205, damage.MAGIC):deal(champ, target)
target:effect(stun.new(2.25))
end

function champ.behaviour(ready, context)
champ.range = 1450
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return xerath