local dash_cast = require("abilities.dash")
local melee_aa_cast = require("abilities.melee_aa")
local none_cast = require("abilities.none")
local ranged_cast = require("abilities.ranged")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local pull = require("effects.pull")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local xin_zhao = {}

-- Constructor
function xin_zhao.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2412,
    armor = 125,
    mr = 77,
    ms = 390,
    sprite = 'xin_zhao.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.0, 175, 249),
    w = ranged_cast.new(5.3, 350),
    w_second = none_cast.new(),
    e = ranged_cast.new(6.4, 650),
    r = dash_cast.new(99, 0, 0),
    r_block = none_cast.new(),
  }
function champ.abilities.aa:start()
self.hits = 2
end


function champ.abilities.aa:hit(target)
self.hits = ( self.hits + 1 ) % 3
if self.hits == 2 then
target:effect(airborne.new(0.7))
end
damage:new(249, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
local hit_cols = {}
for _,dir in pairs ( cast.dir :cone ( 80 , 3 )) do
self.proj = missile.new(self, { dir = dir,
colliders = context.enemies,
size = 120,
speed = 1800,
color = { 0.8,0.5,0.2 },
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
damage:new(211, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.w_second:after_w(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 150,
speed = 6250,
color = { 0.8,0.5,0.2 },
range = 1000,
from = champ,
})
context.delay(0.1, function() context.spawn( self.proj
)
end)
end

function champ.abilities.w_second:hit(target)
damage:new(362, damage.PHYSICAL):deal(champ, target)
target:effect(slow.new(0.5, 0.3))
end

function champ.abilities.e:use(context, cast)
champ:effect(dash.new(2500, cast.pos):on_finish(function()
damage:new(180, damage.PHYSICAL):deal(champ, cast.target)
end))
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 450,
color = { 0.8,0.5,0.2 },
deploy_time = 0.2,
follow = champ,
})
context.spawn( self.proj
)
champ.abilities.r_block:with_r(context, cast)
end

function champ.abilities.r:hit(target)
damage:new(245, damage.PHYSICAL):deal(champ, target)
local dir = target.pos - champ.pos
local dist = 450 - dir :mag ()
local target_pos = target.pos + dir :normalize () * dist
target:effect(pull.new(1200, target_pos))
end

function champ.abilities.r_block:with_r(context, cast)
self.proj = aoe:new(self, { colliders = context.projectiles,
size = 450,
color = { 0.8,0.5,0.2 },
deploy_time = 0.2,
persist_time = 4,
follow = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.r_block:hit(target)
target.despawn = true
end

function champ.behaviour(ready, context)
if context.closest_dist < 175 + 50 then
champ.range = 175
champ.target = context.closest_enemy
else
champ.range = 650
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return xin_zhao