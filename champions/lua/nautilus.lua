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

local nautilus = {}

-- Constructor
function nautilus.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2494,
    armor = 159.4,
    mr = 86.6,
    ms = 440,
    sprite = 'nautilus.jpg',
  })

  champ.abilities = {
    aa = none.new(),
    q = ranged.new(8.57, 1100),
    r = ranged.new(85.7, 850),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 180,
speed = 2000,
color = { 0.3,0.9,0.9 },
range = 1100,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(90, damage.MAGIC):deal(champ, target)
local distance = ( target.pos - champ.pos ):mag ()
local pull_direction = ( target.pos - champ.pos ):normalize ()
local pull_target = target.pos - pull_direction * ( distance * ( 1 - 0.5 ))
local pull_self = champ.pos + pull_direction * ( distance * 0.5 )
target:effect(require("effects.pull").new(1300.0, pull_target):on_finish(function()
damage:new(90, damage.MAGIC):deal(champ, target)
target:effect(require("effects.stun").new(1.18))
end))
champ:effect(require("effects.pull").new(1300.0, pull_self))
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 150,
speed = 500,
color = { 0.3,0.9,0.9 },
range = 850,
from = champ.pos,
to = cast.target,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(250, damage.MAGIC):deal(champ, target)
target:effect(require("effects.airborne").new(1.0))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 1100-50
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 1100+150
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return nautilus