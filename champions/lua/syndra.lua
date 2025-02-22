local champion = require('util.champion')
local aoe = require('projectiles.aoe')
local missile = require('projectiles.missile')
local ability = require('util.ability')
local ranged = require('abilities.ranged')
local splash = require('abilities.splash')
local dash = require('abilities.dash')
local melee_aa = require('abilities.melee_aa')
local buff = require('abilities.buff')
local none = require('abilities.none')
local damage = require('util.damage')
local movement = require('util.movement')
local distances = require('util.distances')
local vec2 = require('util.vec2')

local syndra = {}

-- Constructor
function syndra.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1701.8,
    armor = 75.4,
    mr = 44.25,
    ms = 375,
    sprite = 'syndra.jpg',
  })

  champ.abilities = {
    q = splash.new(3.5, 1000, 210),
    q_push = ability:new(8),
    e = ability:new(8),
    r = ability:new(84),
  }
function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 210,
color = { 0.8,0.5,0.8 },
deploy_time = 0.4,
persist_time = 0,
at = cast.pos,
})
context.spawn( self.proj
)
if champ.abilities.q_push.timer <= 0 then
champ.abilities.q_push.timer = champ.abilities.q_push.cd
self.proj.after = function() champ.abilities.q_push:after_q(context, cast) end
end
if champ.abilities.e.timer <= 0 then
champ.abilities.e.timer = champ.abilities.e.cd
champ.abilities.e:with_q(context, cast)
end
end

function champ.abilities.q:hit(target)
damage:new(350, damage.MAGIC):deal(champ, target)
end

function champ.abilities.q_push:after_q(context, cast)
local hit_cols = champ.abilities.e.hit_cols
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 210,
speed = 2000,
color = { 0.8,0.5,0.8 },
range = 200,
hit_cols = hit_cols,
from = champ.abilities.q.proj.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q_push:hit(target)
damage:new(310, damage.MAGIC):deal(champ, target)
target:effect(require("effects.stun").new(1.0))
end

function champ.abilities.e:with_q(context, cast)
self.hit_cols = {}
for angle = - 0.2 , 0.2 , 0.1 do
local dir = cast.dir :rotate ( angle )
context.spawn( missile.new(self, { dir = dir,
colliders = context.enemies,
size = 120,
speed = 2000,
color = { 0.8,0.5,0.8 },
range = 700,
hit_cols = self.hit_cols,
from = champ,
})
)
end
end

function champ.abilities.e:hit(target)
damage:new(310, damage.MAGIC):deal(champ, target)
local push_pos = target.pos + ( target.pos - champ.pos ):normalize () * 300
target:effect(require("effects.pull").new(1500.0, push_pos))
end

function champ.abilities.r:cast(context)
for _,target in pairs ( distances.in_range_list(champ, context.enemies, 675) ) do
if target.health <= 214 * 5 then
return { target = target }
end
end
return nil
end

function champ.abilities.r:use(context, cast)
for i = 0 , ( 5 - 1 ) * 0.1 , 0.1 do
local proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 100,
speed = 1500,
color = { 0.8,0.5,0.8 },
range = nil,
from = champ,
to = cast.target,
})
context.delay(i, function() context.spawn( proj
)
end)
end
end

function champ.abilities.r:hit(target)
damage:new(214, damage.MAGIC):deal(champ, target)
end

function champ.behaviour(ready, context)
if ready.r and context.closest_enemy.health <= 214 * 5 then
champ.range = 675-50
champ:change_movement(movement.AGGRESSIVE)
elseif ready.q then
champ.range = 1000
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 1000+150
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return syndra