local important_cast = require("abilities.important")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local slow = require("effects.slow")
local stun = require("effects.stun")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local ashe = {}

-- Constructor
function ashe.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1980,
    armor = 66.2,
    mr = 45.6,
    ms = 391,
    sprite = 'ashe.jpg',
    damage_split = { 0.9784982935153583, 0.021501706484641638, 0.0 }
  })
  champ.abilities = {
    aa = ranged_aa_cast.new(0.90, 600, 160, { 0.2,0.7,1.0 }),
    w = ranged_cast.new(4.2, 1200),
    r = important_cast.new(80, 2500),
  }

function champ.abilities.aa:hit(target)
damage:new(160, damage.PHYSICAL):deal(champ, target)
target:effect(slow.new(2.0, 0.25))
end

function champ.abilities.w:use(context, cast)
local hit_cols = {}
for _,dir in pairs ( cast.dir :cone ( 46 , 8 )) do
context.spawn( missile.new(self, { dir = dir,
colliders = context.enemies,
size = 50,
speed = 2000,
color = { 0.2,0.7,1.0 },
range = 1200,
stop_on_hit = true,
hit_cols = hit_cols,
from = champ.pos,
})
)
end
end

function champ.abilities.w:hit(target)
damage:new(209, damage.PHYSICAL):deal(champ, target)
target:effect(slow.new(2.0, 0.25))
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 130,
speed = 1600,
color = { 0.2,0.7,1.0 },
range = 2500,
stop_on_hit = true,
from = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(400, damage.MAGIC):deal(champ, target)
target:effect(stun.new(2.25))
end

function champ.behaviour(ready, context)
champ.range = 600
champ:change_movement(movement.KITE)
end

  return champ
end

return ashe