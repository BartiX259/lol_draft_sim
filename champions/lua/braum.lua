local big_cast = require("abilities.big")
local buff_cast = require("abilities.buff")
local dash_cast = require("abilities.dash")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local resist_buff = require("effects.resist_buff")
local slow = require("effects.slow")
local speed = require("effects.speed")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local braum = {}

-- Constructor
function braum.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2704,
    armor = 169,
    mr = 97,
    ms = 380,
    sprite = 'braum.jpg',
    damage_split = { 0.5713179495121574, 0.4286820504878427, 0.0 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(1.2, 175, 93),
    q = ranged_cast.new(5, 1050),
    w = buff_cast.new(7.4, 650),
    e = dash_cast.new(7.4, 100, 800),
    r = big_cast.new(95.2, 1200, 300),
  }
function champ.abilities.aa:start()
self.counter = 0
end


function champ.abilities.aa:hit(target)
self.counter = ( self.counter + 1 ) % 3
if self.counter == 0 then
target:effect(stun.new(1.0))
end
damage:new(93, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 1700,
color = { 0.2,0.8,0.9 },
range = 1050,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(275, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.0, 0.7))
end

function champ.abilities.w:use(context, cast)
champ:effect(dash.new(1500, cast.target):on_finish(function()
cast.target:effect(resist_buff.new(3.0, 40.0))
champ:effect(resist_buff.new(3.0, 40.0))
end))
end

function champ.abilities.e:use(context, cast)
self.proj = aoe:new(self, { colliders = context.projectiles,
size = 250,
color = { 0.2,0.8,0.9,0.8 },
persist_time = 4,
tick = 0,
follow = champ,
})
champ:effect(speed.new(4, 0.1))
champ:effect(resist_buff.new(4, 80.0))
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
if target.is_missile then
if target.ability.hit then
target.ability :hit ( champ )
end
target.despawn = true
end
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 300,
speed = 1400,
color = { 0.2,0.8,0.9 },
range = 1200,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(300, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.5))
target:effect(slow.new(2.0, 0.5))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 1050-50
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 1050+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return braum