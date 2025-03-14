local dash_cast = require("abilities.dash")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local dash = require("effects.dash")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local renekton = {}

-- Constructor
function renekton.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2442,
    armor = 112.4,
    mr = 72.6,
    ms = 385,
    sprite = 'renekton.jpg',
    damage_split = { 0.9921029928993296, 0.00789700710067025, 0.0 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(1.5, 125, 219),
    q = splash_cast.new(5.5, 240, 480),
    w = ranged_cast.new(7, 175),
    e = dash_cast.new(9, 450, 450),
    r = ranged_cast.new(100, 200),
  }

function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 480,
color = { 0.7,0.3,0.1 },
follow = champ,
deploy_time = 0.05,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
champ :heal ( 110 )
damage:new(330, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
damage:new(178, damage.PHYSICAL):deal(champ, cast.target)
cast.target:effect(stun.new(0.75))
end

function champ.abilities.e:use(context, cast)
champ:effect(dash.new(1200, cast.pos))
end

function champ.abilities.r:use(context, cast)
champ.health = champ.health + 500
self.proj = aoe:new(self, { colliders = context.enemies,
size = 400,
color = { 0.7,0.3,0.1,0.8 },
persist_time = 15,
tick = 0.5,
follow = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(68, damage.MAGIC):deal(champ, target)
end

function champ.behaviour(ready, context)
if context.closest_dist < 125 + 50 then
champ.range = 125
champ.target = context.closest_enemy
else
champ.range = 600
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return renekton