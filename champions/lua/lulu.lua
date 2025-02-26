local vec2 = require("util.vec2")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")
local missile = require("projectiles.missile")
local ranged = require("abilities.ranged")
local buff = require("abilities.buff")
local shield = require("effects.shield")
local damage_buff = require("effects.damage_buff")
local speed = require("effects.speed")
local slow = require("effects.slow")

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
target:effect(slow.new(1.0, 0.2))
end

function champ.abilities.we:use(context, cast)
cast.target:effect(shield.new(2.5, 303.0))
cast.target:effect(speed.new(3.5, 0.25))
cast.target:effect(damage_buff.new(3.5, 0.3))
end

function champ.behaviour(ready, context)
champ.range = 925
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return lulu