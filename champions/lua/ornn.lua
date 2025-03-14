local big_cast = require("abilities.big")
local melee_aa_cast = require("abilities.melee_aa")
local none_cast = require("abilities.none")
local splash_cast = require("abilities.splash")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local ornn = {}

-- Constructor
function ornn.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2650,
    armor = 185,
    mr = 127,
    ms = 380,
    sprite = 'ornn.jpg',
    damage_split = { 0.4302472477892077, 0.5697527522107922, 0.0 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(1.2, 175, 111),
    e = splash_cast.new(7.7, 800, 360),
    r = big_cast.new(100, 2500, 340),
    r_recast = none_cast.new(),
  }

function champ.abilities.e:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 360,
color = { 0.8,0.4,0.2 },
deploy_time = 0.35,
follow = champ,
})
context.spawn( self.proj
)
champ:effect(dash.new(1600, cast.pos))
end

function champ.abilities.e:hit(target)
damage:new(298, damage.PHYSICAL):deal(champ, target)
target:effect(airborne.new(1.25))
end

function champ.abilities.r:use(context, cast)
local cast_pos = cast.dir * 2500
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 340,
speed = 1200,
color = { 0.8,0.4,0.2 },
range = 2500,
from = cast_pos,
to = champ,
})
context.spawn( self.proj
)
self.proj.after = function() champ.abilities.r_recast:after_r(context, cast) end
end

function champ.abilities.r:hit(target)
damage:new(125, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.0, 0.5))
end

function champ.abilities.r_recast:after_r(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 340,
speed = 1900,
color = { 0.8,0.4,0.2 },
from = champ.abilities.r.proj,
to = context.closest_enemy.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r_recast:hit(target)
damage:new(325, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.0))
end

function champ.behaviour(ready, context)
if ready.e then
champ.range = 800
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 800+250
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return ornn