local dash_cast = require("abilities.dash")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local ezreal = {}

-- Constructor
function ezreal.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1824,
    armor = 66.4,
    mr = 45.6,
    ms = 360,
    sprite = 'ezreal.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(0.83, 550, 208, { 0.8,0.8,0.4 }),
    q = ranged_cast.new(3.75, 1200),
    e = dash_cast.new(11.7, 475, 700),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 2000,
color = { 0.8,0.8,0.4 },
range = 1200,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(390, damage.PHYSICAL):deal(champ, target)
for _,ability in pairs ( champ.abilities ) do
ability.timer = ability.timer - 1.5
end
end

function champ.abilities.e:use(context, cast)
champ.pos = cast.pos
if context.closest_dist < 700 + 50 then
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 120,
speed = 2000,
color = { 0.8,0.8,0.4 },
range = nil,
from = champ.pos,
to = context.closest_enemy,
})
context.spawn( self.proj
)
end
end

function champ.abilities.e:hit(target)
damage:new(280, damage.MAGIC):deal(champ, target)
end

function champ.behaviour(ready, context)
champ:change_movement(movement.KITE)
champ.range = 1200
end

  return champ
end

return ezreal