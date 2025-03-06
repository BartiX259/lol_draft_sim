local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local airborne = require("effects.airborne")
local slow = require("effects.slow")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local vel_koz = {}

-- Constructor
function vel_koz.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1900,
    armor = 93,
    mr = 65.6,
    ms = 385,
    sprite = 'vel_koz.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.3, 525, 82.7, { 0.9,0.5,0.8 }),
    q = ranged_cast.new(5.4, 1000),
    q_split = ability:new(5.4),
    w = ranged_cast.new(11.1, 850),
    w_second_hit = ability:new(11.1),
    e = splash_cast.new(8.9, 800, 220),
    r = ranged_cast.new(59.3, 1300),
  }

function champ.abilities.q:use(context, cast)
self.hit_cols = {}
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 100,
speed = 1500,
color = { 0.9,0.5,0.8 },
range = 1000,
stop_on_hit = true,
hit_cols = self.hit_cols,
from = champ.pos,
})
context.spawn( self.proj
)
if champ.abilities.q_split.timer <= 0 then
champ.abilities.q_split.timer = champ.abilities.q_split.cd
self.proj.after = function() champ.abilities.q_split:after_q(context, cast) end
end
end

function champ.abilities.q:hit(target)
damage:new(360, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.0, 0.3))
end

function champ.abilities.q_split:after_q(context, cast)
local hit_cols = champ.abilities.q.hit_cols
for _,dir in pairs ( cast.dir :perp ( 2 )) do
local speed = 1500 * 2
context.spawn( missile.new(self, { dir = dir,
colliders = context.enemies,
size = 100,
speed = speed,
color = { 0.9,0.5,0.8 },
range = 1000,
stop_on_hit = true,
hit_cols = hit_cols,
from = champ.abilities.q.proj,
})
)
end
end

function champ.abilities.q_split:hit(target)
damage:new(360, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.0, 0.3))
end

function champ.abilities.w:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 80,
speed = 2000,
color = { 0.9,0.5,0.8 },
range = 850,
from = champ.pos,
})
context.spawn( self.proj
)
if champ.abilities.w_second_hit.timer <= 0 then
champ.abilities.w_second_hit.timer = champ.abilities.w_second_hit.cd
self.proj.after = function() champ.abilities.w_second_hit:after_w(context, cast) end
end
end

function champ.abilities.w:hit(target)
damage:new(168, damage.MAGIC):deal(champ, target)
end

function champ.abilities.w_second_hit:after_w(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 80,
speed = 2000,
color = { 0.9,0.5,0.8 },
range = 850,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.w_second_hit:hit(target)
damage:new(168, damage.MAGIC):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 220,
color = { 0.9,0.5,0.8 },
deploy_time = 0.75,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(192, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(0.75))
end

function champ.abilities.r:use(context, cast)
local range = 1500
champ:effect(stun.new(2.5))
for i = 0 , 2.4 , 0.2 do
context.delay(i, function()
context.spawn( missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 100,
speed = 2500,
color = { 0.9,0.5,0.8 },
range = range,
from = champ.pos,
to = context.closest_enemy.pos,
})
)
end)
end
end

function champ.abilities.r:hit(target)
damage:new(89, damage.MAGIC):deal(champ, target)
end

function champ.behaviour(ready, context)
champ.range = 1000
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return vel_koz