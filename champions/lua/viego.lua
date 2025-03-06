local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local dash = require("effects.dash")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local viego = {}

-- Constructor
function viego.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2438,
    armor = 104.2,
    mr = 76.6,
    ms = 390,
    sprite = 'viego.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(0.95, 200, 252),
    q = ranged_cast.new(2.8, 350),
    w = ranged_cast.new(7, 400),
    r = ability:new(100),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 150,
speed = 2000,
color = { 0.3,0.7,0.6 },
range = 350,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(260, damage.PHYSICAL):deal(champ, target)
champ :heal ( 70 )
end

function champ.abilities.w:use(context, cast)
champ:effect(dash.new(1200, cast.pos):on_finish(function()
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 1200,
color = { 0.3,0.7,0.6 },
range = 400,
from = champ.pos,
})
context.spawn( self.proj
)
end))
end

function champ.abilities.w:hit(target)
damage:new(250, damage.MAGIC):deal(champ, target)
target:effect(stun.new(1.0))
end

function champ.abilities.r:cast(context)
for _,enemy in pairs ( distances.in_range_list(champ, context.enemies, 500) ) do
if enemy.health + 150 < 742 then
local dir = enemy.pos - champ.pos
return {
target = enemy ,
pos = enemy.pos + dir :normalize () * 100 ,
mag = dir :mag (),
}
end
end
end

function champ.abilities.r:use(context, cast)
local speed = cast.mag / 0.5
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.3,0.7,0.6 },
deploy_time = 0.5,
at = cast.pos,
})
context.spawn( self.proj
)
champ:effect(dash.new(speed, cast.pos))
end

function champ.abilities.r:hit(target)
damage:new(742, damage.PHYSICAL):deal(champ, target)
end

function champ.behaviour(ready, context)
if context.closest_dist < 200 + 50 then
champ.range = 200
champ.target = context.closest_enemy
else
champ.range = 400+150
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return viego