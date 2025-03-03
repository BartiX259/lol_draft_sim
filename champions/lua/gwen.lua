local dash_cast = require("abilities.dash")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local damage_buff = require("effects.damage_buff")
local dash = require("effects.dash")
local resist_buff = require("effects.resist_buff")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local gwen = {}

-- Constructor
function gwen.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2150,
    armor = 116,
    mr = 77,
    ms = 385,
    sprite = 'gwen.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(0.88, 255, 205),
    q = ranged_cast.new(2.92, 220),
    w = dash_cast.new(15, 0, 0),
    e = dash_cast.new(9.17, 450, 500),
    r = ranged_cast.new(83, 1350),
  }

function champ.abilities.aa:hit(target)
damage:new(205, damage.MAGIC):deal(champ, target)
end

function champ.abilities.q:use(context, cast)
local hit_cols = {}
for i = 1 , 6 do
for _,dir in pairs ( cast.dir :cone ( 35 , 2 )) do
local del = ( i - 1 )* 0.1
context.delay(del, function()
local at = champ.pos + dir * 220 / 2
context.spawn( aoe:new(self, { colliders = context.enemies,
size = 250,
color = { 0.6,0.8,1.0 },
deploy_time = 0.1,
persist_time = 0.1,
at = at,
hit_cols = hit_cols,
})
)
end)
end
end
end

function champ.abilities.q:hit(target)
damage:new(245, damage.MAGIC):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
self.proj = aoe:new(self, { colliders = context.projectiles,
size = 480,
color = { 0.6,0.8,1.0,0.7 },
persist_time = 4,
follow = champ,
})
champ:effect(resist_buff.new(4, 40.0))
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
target.hit_cols [ champ ] = true
end

function champ.abilities.e:use(context, cast)
champ:effect(dash.new(1400, cast.pos))
champ:effect(damage_buff.new(4.0, 0.25))
end

function champ.abilities.r:use(context, cast)
for i = 1 , 5 do
local proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 80,
speed = 2200,
color = { 0.6,0.8,1.0 },
range = 1350,
from = champ.pos,
})
local del = ( i - 1 ) * 0.1
context.delay(del, function() context.spawn( proj
)
end)
end
end

function champ.abilities.r:hit(target)
damage:new(120, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.5, 0.5))
end

function champ.behaviour(ready, context)
if context.closest_dist < 255 + 50 then
champ.range = 255
champ.target = context.closest_enemy
elseif ready.w then
champ.range = 0
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 0+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return gwen