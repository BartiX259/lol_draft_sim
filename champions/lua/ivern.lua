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

local ivern = {}

-- Constructor
function ivern.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2217,
    armor = 93.4,
    mr = 47.6,
    ms = 375,
    sprite = 'ivern.jpg',
  })

  champ.abilities = {
    q = ranged.new(6.86, 1150),
    e = buff.new(4.83, 750),
  }
function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 140,
speed = 1300,
color = { 0.2,0.8,0.4 },
range = 1150,
stop_on_hit = true,
from = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(281, damage.MAGIC):deal(champ, target)
target:effect(require("effects.root").new(2.0))
end

function champ.abilities.e:use(context, cast)
cast.target:effect(require("effects.shield").new(2.0, 414.0))
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.2,0.8,0.4 },
deploy_time = 0.1,
persist_time = 0.2,
follow = cast.target,
})
context.delay(2, function() context.spawn( self.proj
)
end)
end

function champ.abilities.e:hit(target)
damage:new(277, damage.MAGIC):deal(champ, target)
target:effect(require("effects.slow").new(2.0, 0.6))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 1150-50
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 1150+150
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return ivern