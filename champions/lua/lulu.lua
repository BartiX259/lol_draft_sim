local buff_cast = require("abilities.buff")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local damage_buff = require("effects.damage_buff")
local shield = require("effects.shield")
local slow = require("effects.slow")
local speed = require("effects.speed")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")
local vec2 = require("util.vec2")

local lulu = {}

-- Constructor
function lulu.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1699,
    armor = 84.8,
    mr = 45.6,
    ms = 370,
    sprite = 'lulu.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1, 550, 84, { 0.8,0.5,0.8 }),
    q = ranged_cast.new(5.83, 950),
    w = ability:new(12.5),
    e = buff_cast.new(6.67, 650),
  }

function champ.abilities.q:use(context, cast)
local dir = ( cast.dir + vec2.random () / 5 ):normalize ()
context.spawn( missile.new(self, { dir = dir,
colliders = context.enemies,
size = 120,
speed = 1450,
color = { 0.8,0.5,0.8 },
range = 950,
from = champ.pos,
})
)
dir = ( cast.dir + vec2.random () / 5 ):normalize ()
context.delay(0.1, function() context.spawn( missile.new(self, { dir = dir,
colliders = context.enemies,
size = 120,
speed = 1450,
color = { 0.8,0.5,0.8 },
range = 950,
from = champ.pos,
})
)
end)
end

function champ.abilities.q:hit(target)
damage:new(270, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.0, 0.8))
end

function champ.abilities.w:with_e(context, cast)
cast.target:effect(speed.new(4.0, 0.31))
cast.target:effect(damage_buff.new(4.0, 0.35))
end

function champ.abilities.e:use(context, cast)
cast.target:effect(shield.new(2.5, 326.0))
if champ.abilities.w.timer <= 0 then
champ.abilities.w.timer = champ.abilities.w.cd
champ.abilities.w:with_e(context, cast)
end
end

function champ.behaviour(ready, context)
champ.range = 550
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return lulu