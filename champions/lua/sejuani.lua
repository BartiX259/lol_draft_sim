local important_cast = require("abilities.important")
local melee_aa_cast = require("abilities.melee_aa")
local none_cast = require("abilities.none")
local ranged_cast = require("abilities.ranged")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local pull = require("effects.pull")
local slow = require("effects.slow")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local sejuani = {}

-- Constructor
function sejuani.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2718,
    armor = 131.9,
    mr = 106.6,
    ms = 380,
    sprite = 'sejuani.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.2, 175, 114),
    q = ranged_cast.new(11.3, 650),
    w = ranged_cast.new(4.5, 350),
    w_second = none_cast.new(),
    r = important_cast.new(95.7, 1100),
    r_explosion = ability:new(95.7),
  }

function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 220,
color = { 0.5,0.7,1.0 },
follow = champ,
tick = 0,
re_hit = false,
})
self.dir = cast.dir
context.spawn( self.proj
)
champ:effect(dash.new(1450, cast.pos))
end

function champ.abilities.q:hit(target)
damage:new(240, damage.MAGIC):deal(champ, target)
self.proj.despawn = true
champ :del_effect ( "dash" )
local target_pos = target.pos + self.dir * 90
target:effect(airborne.new(1.0))
target:effect(pull.new(600, target_pos))
end

function champ.abilities.w:use(context, cast)
local hit_cols = {}
for _,dir in pairs ( cast.dir :cone ( 45 , 3 )) do
self.proj = missile.new(self, { dir = dir,
colliders = context.enemies,
size = 120,
speed = 1500,
color = { 0.5,0.7,1.0 },
range = 350,
hit_cols = hit_cols,
from = champ.pos,
})
context.spawn( self.proj
)
end
self.proj.after = function() champ.abilities.w_second:after_w(context, cast) end
end

function champ.abilities.w:hit(target)
damage:new(120, damage.PHYSICAL):deal(champ, target)
target:effect(slow.new(0.5, 0.3))
end

function champ.abilities.w_second:after_w(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 150,
speed = 1500,
color = { 0.5,0.7,1.0 },
range = 400,
from = champ,
})
context.delay(0.1, function() context.spawn( self.proj
)
end)
end

function champ.abilities.w_second:hit(target)
damage:new(200, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 220,
speed = 1600,
color = { 0.5,0.7,1.0 },
range = 1100,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
if champ.abilities.r_explosion.timer <= 0 then
champ.abilities.r_explosion.timer = champ.abilities.r_explosion.cd
self.proj.after = function() champ.abilities.r_explosion:after_r(context, cast) end
end
end

function champ.abilities.r:hit(target)
damage:new(183, damage.MAGIC):deal(champ, target)
target:effect(stun.new(1.5))
end

function champ.abilities.r_explosion:after_r(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 400,
color = { 0.5,0.7,1.0 },
at = champ.abilities.r.proj,
})
context.spawn( self.proj
)
end

function champ.abilities.r_explosion:hit(target)
damage:new(270, damage.MAGIC):deal(champ, target)
target:effect(slow.new(3.0, 0.8))
end

function champ.behaviour(ready, context)
if context.closest_dist < 175 + 50 then
champ.range = 175
champ.target = context.closest_enemy
elseif ready.q then
champ.range = 650
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 350+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return sejuani