local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local root = require("effects.root")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local jhin = {}

-- Constructor
function jhin.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1939,
    armor = 80,
    mr = 46,
    ms = 395,
    sprite = 'jhin.jpg',
    damage_split = { 1.0, 0.0, 0.0 }
  })
  champ.abilities = {
    aa = ranged_aa_cast.new(1, 550, 274, { 0.6,0.1,0.6 }),
    q = ranged_aa_cast.new(4.5, 580, 347, { 0.6,0.1,0.6 }),
    w = ranged_cast.new(10.9, 2520),
  }
function champ.abilities.aa:start()
self.counter = 0
end


function champ.abilities.aa:hit(target)
self.counter = ( self.counter + 1 ) % 4
if self.counter == 0 then
damage:new(507.0, damage.PHYSICAL):deal(champ, target)
else
damage:new(274, damage.PHYSICAL):deal(champ, target)
end
end


function champ.abilities.w:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 90,
speed = 1600,
color = { 0.6,0.1,0.6 },
range = 2520,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
damage:new(337, damage.PHYSICAL):deal(champ, target)
target:effect(root.new(2.25))
end

function champ.behaviour(ready, context)
champ.range = 550
champ:change_movement(movement.KITE)
end

  return champ
end

return jhin