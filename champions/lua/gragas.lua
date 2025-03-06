local big_cast = require("abilities.big")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local pull = require("effects.pull")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local gragas = {}

-- Constructor
function gragas.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2470,
    armor = 105,
    mr = 76.6,
    ms = 375,
    sprite = 'gragas.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.2, 125, 150),
    q = ranged_cast.new(4.5, 850),
    e = ranged_cast.new(6.3, 600),
    r = big_cast.new(81, 1050, 350),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 275,
speed = 1300,
color = { 0.8,0.5,0.3 },
range = 850,
from = champ.pos,
to = cast.pos,
})
self.proj.next = aoe:new(self, { colliders = context.enemies,
size = 275,
color = { 0.8,0.5,0.3 },
deploy_time = 0.1,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(368, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.0, 0.9))
end

function champ.abilities.e:use(context, cast)
self.dir = cast.dir
self.proj = aoe:new(self, { colliders = context.enemies,
size = 200,
color = { 0.8,0.5,0.3 },
follow = champ,
tick = 0,
re_hit = false,
})
context.spawn( self.proj
)
champ:effect(dash.new(1400, cast.pos))
end

function champ.abilities.e:hit(target)
damage:new(244, damage.MAGIC):deal(champ, target)
self.proj.despawn = true
champ :del_effect ( "dash" )
local target_pos = target.pos + self.dir * 90
target:effect(airborne.new(1.0))
target:effect(pull.new(600, target_pos))
champ :heal ( 85 )
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 350,
speed = 1600,
color = { 0.8,0.5,0.3 },
range = 1050,
from = champ.pos,
to = cast.pos,
})
self.proj.next = aoe:new(self, { colliders = context.enemies,
size = 350,
color = { 0.8,0.5,0.3 },
deploy_time = 0.1,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(522, damage.MAGIC):deal(champ, target)
local knockback_dir = ( target.pos - self.proj.pos ):normalize ()
local knockback_dist = 400
local target_pos = target.pos + knockback_dir * knockback_dist
target:effect(pull.new(1800, target_pos))
end

function champ.behaviour(ready, context)
if ready.e then
champ.range = 600
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 850+100
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return gragas