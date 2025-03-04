local big_cast = require("abilities.big")
local buff_cast = require("abilities.buff")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local airborne = require("effects.airborne")
local damage_buff = require("effects.damage_buff")
local pull = require("effects.pull")
local shield = require("effects.shield")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local janna = {}

-- Constructor
function janna.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1800,
    armor = 67,
    mr = 45.6,
    ms = 385,
    sprite = 'janna.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.176, 550, 95, { 0.7,0.9,1.0 }),
    q = ranged_cast.new(13.33, 1760),
    w = ranged_cast.new(5.71, 550),
    e = buff_cast.new(11.43, 800),
    r = big_cast.new(109.52, 725, 725),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 240,
speed = 1408,
color = { 0.7,0.9,1.0 },
range = 1760,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(249, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.25))
end

function champ.abilities.w:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 80,
speed = 1600,
color = { 0.7,0.9,1.0 },
range = 550,
from = champ.pos,
to = cast.target,
})
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
damage:new(215, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.0, 0.36))
end

function champ.abilities.e:use(context, cast)
cast.target:effect(shield.new(4.0, 284.0))
cast.target:effect(damage_buff.new(4.0, 0.38))
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 725,
color = { 0.7,0.9,1.0 },
persist_time = 3,
tick = 0.25,
follow = champ,
re_hit = false,
}):on_impact(function()
for _,ally in pairs ( distances.in_range_list ( champ , context.allies , 725 )) do
ally.health = ally.health + 35
end
end)
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(47.5, damage.MAGIC):deal(champ, target)
local knockback_dir = ( target.pos - champ.pos ):normalize ()
local knockback_dist = 400
local target_pos = target.pos + knockback_dir * knockback_dist
target:effect(pull.new(1800, target_pos))
end

function champ.behaviour(ready, context)
champ.range = 550
champ:change_movement(movement.PEEL)
end

  return champ
end

return janna