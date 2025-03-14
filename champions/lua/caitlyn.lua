local dash_cast = require("abilities.dash")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local dash = require("effects.dash")
local slow = require("effects.slow")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local caitlyn = {}

-- Constructor
function caitlyn.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1950,
    armor = 70,
    mr = 40,
    ms = 370,
    sprite = 'caitlyn.jpg',
    damage_split = { 0.954524361948956, 0.045475638051044084, 0.0 }
  })
  champ.abilities = {
    aa = ranged_aa_cast.new(1, 650, 220, { 0.9,0.7,0.4 }),
    q = ranged_cast.new(6.3, 1250),
    e = dash_cast.new(8.5, 400, 800),
  }
function champ.abilities.aa:start()
self.counter = 5
end


function champ.abilities.aa:hit(target)
self.counter = ( self.counter + 1 ) % 5
if self.counter == 0 then
damage:new(400.0, damage.PHYSICAL):deal(champ, target)
else
damage:new(220, damage.PHYSICAL):deal(champ, target)
end
end

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 80,
speed = 2200,
color = { 0.9,0.7,0.4 },
range = 1250,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(450, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
local dpos = champ.pos + cast.dir * 400
champ:effect(dash.new(1600, dpos))
local net_dir = - cast.dir
self.proj = missile.new(self, { dir = net_dir,
colliders = context.enemies,
size = 200,
speed = 1600,
color = { 0.9,0.9,0.9,0.9 },
range = 800,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(280, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.5, 0.5))
end

function champ.behaviour(ready, context)
champ.range = 650
champ:change_movement(movement.KITE)
end

  return champ
end

return caitlyn