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

local orianna = {}

-- Constructor
function orianna.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1789.5,
    armor = 66,
    mr = 40,
    ms = 370,
    sprite = 'orianna.jpg',
  })

  champ.abilities = {
    q = splash.new(2.7, 1025, 175),
    w = ability:new(5),
    r = ability:new(90),
  }
function champ.abilities.q:use(context, cast)
local cast_pos = cast.pos
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 175,
speed = 1400,
color = { 0.3,0.5,0.8 },
range = 1025,
from = champ.pos,
to = cast_pos,
})
self.proj.next = aoe:new(self, { colliders = nil,
size = 175,
color = { 0.3,0.5,0.8 },
persist_time = 1,
at = cast_pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(300, damage.MAGIC):deal(champ, target)
end

function champ.abilities.w:cast(context)
return champ.abilities.q.proj and distances.in_range ( champ.abilities.q.proj , context.enemies , 225 / 2 + 30 ) >= 1
end

function champ.abilities.w:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 225,
color = { 0.3,0.5,0.8 },
at = champ.abilities.q.proj,
follow = champ.abilities.q.proj,
})
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
damage:new(400, damage.MAGIC):deal(champ, target)
target:effect(require("effects.slow").new(1.0, 0.2))
end

function champ.abilities.r:cast(context)
return champ.abilities.q.proj and distances.in_range ( champ.abilities.q.proj , context.enemies , 415 / 2 ) >= math.clamp ( # context.enemies - 1 , 1 , 3 )
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 415,
color = { 0.3,0.5,0.8,0.7 },
deploy_time = 0.2,
at = champ.abilities.q.proj,
follow = champ.abilities.q.proj,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(650, damage.MAGIC):deal(champ, target)
target:effect(require("effects.pull").new(1200.0, self.proj))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 1025-50
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 1025+200
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return orianna