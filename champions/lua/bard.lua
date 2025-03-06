local big_cast = require("abilities.big")
local buff_cast = require("abilities.buff")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local slow = require("effects.slow")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local bard = {}

-- Constructor
function bard.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2276,
    armor = 94,
    mr = 76,
    ms = 390,
    sprite = 'bard.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.1, 550, 155, { 0.8,0.9,0.7 }),
    q = ranged_cast.new(8.3, 900),
    w = buff_cast.new(11.7, 800),
    r = big_cast.new(79.2, 2500, 450),
  }

function champ.abilities.aa:hit(target)
damage:new(155, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.0, 0.45))
end

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 1500,
color = { 0.8,0.9,0.7 },
range = 900,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(320, damage.MAGIC):deal(champ, target)
target:effect(stun.new(1.8))
end

function champ.abilities.w:use(context, cast)
cast.target :heal ( 260 )
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 450,
color = { 0.8,0.9,0.7 },
deploy_time = 0.5,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
target:effect(stun.new(1.0))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 900
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 900+100
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return bard