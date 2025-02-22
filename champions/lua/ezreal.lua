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

local ezreal = {}

-- Constructor
function ezreal.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1604.2,
    armor = 70.3,
    mr = 42.8,
    ms = 370,
    sprite = 'ezreal.jpg',
  })

  champ.abilities = {
    q = ranged.new(4, 1300),
    e = dash.new(11.5, 475, 700),
  }
function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 2000,
color = { 0.8,0.8,0.4 },
range = 1300,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(380, damage.PHYSICAL):deal(champ, target)
for _,ability in pairs ( champ.abilities ) do
ability.timer = ability.timer - 1.5
end
end

function champ.abilities.e:use(context, cast)
champ.pos = cast.pos
if context.closest_dist < 700 + 50 then
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 120,
speed = 2000,
color = { 0.8,0.8,0.4 },
range = 700,
from = champ.pos,
to = context.closest_enemy,
})
context.spawn( self.proj
)
end
end

function champ.abilities.e:hit(target)
damage:new(340, damage.MAGIC):deal(champ, target)
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 1300-100
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 1300+50
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return ezreal