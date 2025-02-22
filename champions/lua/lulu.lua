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

local lulu = {}

-- Constructor
function lulu.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1602.4,
    armor = 70,
    mr = 41,
    ms = 375,
    sprite = 'lulu.jpg',
  })

  champ.abilities = {
    q = ranged.new(5.1, 925),
    we = buff.new(6, 650),
  }
function champ.abilities.q:use(context, cast)
local dir = ( cast.dir + vec2.random () / 5 ):normalize ()
context.spawn( missile.new(self, { dir = dir,
colliders = context.enemies,
size = 120,
speed = 1600,
color = { 0.8,0.5,0.8 },
range = 925,
from = champ.pos,
})
)
dir = ( cast.dir + vec2.random () / 5 ):normalize ()
context.delay(0.1, function() context.spawn( missile.new(self, { dir = dir,
colliders = context.enemies,
size = 120,
speed = 1600,
color = { 0.8,0.5,0.8 },
range = 925,
from = champ.pos,
})
)
end)
end

function champ.abilities.q:hit(target)
damage:new(156, damage.MAGIC):deal(champ, target)
target:effect(require("effects.slow").new(1.0, 0.2))
end

function champ.abilities.we:use(context, cast)
cast.target:effect(require("effects.shield").new(2.5, 303.0))
cast.target:effect(require("effects.speed").new(3.5, 0.25))
cast.target:effect(require("effects.damage_buff").new(3.5, 0.3))
end

function champ.behaviour(ready, context)
champ.range = 925
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return lulu