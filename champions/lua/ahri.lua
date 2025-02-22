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

local ahri = {}

-- Constructor
function ahri.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1728.8,
    armor = 72.5,
    mr = 44.25,
    ms = 375,
    sprite = 'ahri.jpg',
  })

  champ.abilities = {
    q = splash.new(4, 900, 200),
    q_ret = none.new(),
    e = ranged.new(8, 1000),
    r = dash.new(8, 500, champ.range),
  }
function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 200,
speed = 1750,
color = { 0.4,0.5,0.9 },
range = 900,
from = champ.pos,
})
context.spawn( self.proj
)
self.proj.after = function() champ.abilities.q_ret:after_q(context, cast) end
end

function champ.abilities.q:hit(target)
damage:new(280, damage.MAGIC):deal(champ, target)
end

function champ.abilities.q_ret:after_q(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 200,
speed = 1750,
color = { 0.4,0.5,0.9 },
from = champ.abilities.q.proj,
to = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.q_ret:hit(target)
damage:new(280, damage.TRUE):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 1550,
color = { 1,0.2,0.8 },
range = 1000,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(270, damage.MAGIC):deal(champ, target)
target:effect(require("effects.charm").new(1.5, 100.0, champ))
end

function champ.abilities.r:use(context, cast)
champ:effect(require("effects.pull").new(1300.0, cast.pos):on_finish(function()
if context.closest_dist < 900 then
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 100,
speed = 1000,
color = { 0.4,0.5,0.9 },
from = champ.pos,
to = cast.target,
range = nil,
})
context.spawn( self.proj
)
end
end))
end

function champ.abilities.r:hit(target)
damage:new(200, damage.MAGIC):deal(champ, target)
end

function champ.behaviour(ready, context)
if ready.e then
champ.range = 1000
champ:change_movement(movement.AGGRESSIVE)
elseif ready.q then
champ.range = 900
champ:change_movement(movement.PASSIVE)
else
champ.range = 900+150
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return ahri