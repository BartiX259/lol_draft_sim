local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local airborne = require("effects.airborne")
local silence = require("effects.silence")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local cho_gath = {}

-- Constructor
function cho_gath.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2952,
    armor = 85.1,
    mr = 76.6,
    ms = 395,
    sprite = 'cho_gath.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.2, 125, 119.4),
    q = splash_cast.new(7.2, 950, 250),
    w = ranged_cast.new(9.7, 650),
    r = ability:new(70),
  }

function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 250,
color = { 0.6,0.3,0.6 },
deploy_time = 0.627,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(220, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.0))
target:effect(slow.new(1.5, 0.6))
end

function champ.abilities.w:use(context, cast)
local hit_cols = {}
for _,dir in pairs ( cast.dir :cone ( 60 , 5 )) do
self.proj = missile.new(self, { dir = dir,
colliders = context.enemies,
size = 100,
speed = 2000,
color = { 0.6,0.3,0.6 },
range = 650,
hit_cols = hit_cols,
from = champ.pos,
})
context.spawn( self.proj
)
end
end

function champ.abilities.w:hit(target)
damage:new(210, damage.MAGIC):deal(champ, target)
target:effect(silence.new(2.0))
end

function champ.abilities.r:cast(context)
if champ.target and champ.target.pos :distance ( champ.pos ) < 175 and ( champ.target.health < 590 or champ.health / champ.max_health < 0.3 ) then
return { target = champ.target }
end
return nil
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = nil,
size = 200,
color = { 0.6,0.3,0.6 },
deploy_time = 0.25,
follow = cast.target,
}):on_impact(function()
damage:new(590, damage.TRUE):deal(champ, cast.target)
end)
context.spawn( self.proj
)
end

function champ.behaviour(ready, context)
if context.closest_dist < 125 + 50 then
champ.range = 125
champ.target = context.closest_enemy
elseif ready.q then
champ.range = 950
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 950+100
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return cho_gath