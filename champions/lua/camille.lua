local dash_cast = require("abilities.dash")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local dash = require("effects.dash")
local slow = require("effects.slow")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local camille = {}

-- Constructor
function camille.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2588,
    armor = 105,
    mr = 77,
    ms = 385,
    sprite = 'camille.jpg',
    damage_split = { 0.23341800194801474, 0.001890720192509692, 0.7646912778594755 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(0.93, 175, 154),
    q = ranged_cast.new(4.5, 225),
    w = ranged_cast.new(10, 600),
    e = dash_cast.new(11, 300, 800),
    e_recast = ability:new(11),
    r = ranged_cast.new(105, 450),
  }

function champ.abilities.q:use(context, cast)
damage:new(520, damage.TRUE):deal(champ, cast.target)
end

function champ.abilities.w:use(context, cast)
local hit_cols = {}
for _,dir in pairs ( cast.dir :cone ( 70 , 5 )) do
self.proj = missile.new(self, { dir = dir,
colliders = context.enemies,
size = 100,
speed = 1900,
color = { 0.8,0.8,0.8 },
range = 600,
hit_cols = hit_cols,
from = champ.pos,
})
context.spawn( self.proj
)
end
end

function champ.abilities.w:hit(target)
damage:new(180, damage.PHYSICAL):deal(champ, target)
target:effect(slow.new(2.0, 0.8))
end

function champ.abilities.e:use(context, cast)
local persist_time = cast.mag / 1400
self.proj = aoe:new(self, { colliders = nil,
color = { 0.8,0.8,0.8 },
persist_time = persist_time,
follow = champ,
size = 1,
})
context.spawn( self.proj
)
champ:effect(dash.new(1400, cast.pos))
if champ.abilities.e_recast.timer <= 0 then
champ.abilities.e_recast.timer = champ.abilities.e_recast.cd
self.proj.after = function() champ.abilities.e_recast:after_e(context, cast) end
end
end

function champ.abilities.e_recast:after_e(context, cast)
local cpos
if context.closest_dist < 750 then
cpos = champ.pos + ( context.closest_enemy.pos - champ.pos ):normalize () * 750
else
cpos = champ.pos + ( champ.pos - context.closest_enemy.pos ):normalize () * 750 / 2
end
champ:effect(dash.new(1400, cpos))
self.proj = aoe:new(self, { colliders = context.enemies,
color = { 0.8,0.8,0.8 },
follow = champ,
size = 100,
tick = 0,
re_hit = false,
})
context.spawn( self.proj
)
end

function champ.abilities.e_recast:hit(target)
damage:new(190, damage.PHYSICAL):deal(champ, target)
target:effect(stun.new(0.75))
self.proj.despawn = true
champ :del_effect ( "dash" )
end

function champ.abilities.r:use(context, cast)
champ:effect(dash.new(1600, cast.target):on_finish(function()
self.proj = aoe:new(self, { colliders = context.enemies,
color = { 0.8,0.8,0.8 },
at = champ.pos,
size = 100,
})
context.spawn( self.proj
)
end))
end

function champ.abilities.r:hit(target)
damage:new(30, damage.MAGIC):deal(champ, target)
target:effect(stun.new(0.5))
end

function champ.behaviour(ready, context)
if context.closest_dist < 175 + 100 then
champ.range = 175
champ.target = context.closest_enemy
else
champ.range = 650
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return camille