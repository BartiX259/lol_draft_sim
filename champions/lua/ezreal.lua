local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")
local missile = require("projectiles.missile")
local dash = require("abilities.dash")
local ranged = require("abilities.ranged")
local ranged_aa = require("abilities.ranged_aa")

local ezreal = {}

-- Constructor
function ezreal.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1824,
    armor = 80.4,
    mr = 45.6,
    ms = 385,
    sprite = 'ezreal.jpg',
  })

  champ.abilities = {
    aa = ranged_aa.new(1, 550, 203, { 0.8,0.8,0.4 }),
    q = ranged.new(4.5, 1200),
    e = dash.new(14, 475, 700),
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
damage:new(489, damage.PHYSICAL):deal(champ, target)
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
range = 700,
from = champ.pos,
to = context.closest_enemy,
})
context.spawn( self.proj
)
end
end

function champ.abilities.e:hit(target)
damage:new(387, damage.MAGIC):deal(champ, target)
end

function champ.behaviour(ready, context)
champ:change_movement(movement.KITE)
champ.range = 1200
end

  return champ
end

return ezreal