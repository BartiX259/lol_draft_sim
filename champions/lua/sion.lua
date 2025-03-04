local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local shield = require("effects.shield")
local stun = require("effects.stun")
local unstoppable = require("effects.unstoppable")
local aoe = require("projectiles.aoe")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local sion = {}

-- Constructor
function sion.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2678,
    armor = 109.4,
    mr = 88.6,
    ms = 395,
    sprite = 'sion.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.2, 175, 130),
    q = ranged_cast.new(6, 400),
    w = ranged_cast.new(8, 300),
    r = ranged_cast.new(90, 750),
  }

function champ.abilities.q:use(context, cast)
champ:effect(stun.new(1))
local cast_pos = ( cast.pos + champ.pos ) / 2
self.proj = aoe:new(self, { colliders = context.enemies,
size = 400,
color = { 0.6,0.4,0.4 },
deploy_time = 1,
at = cast_pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(430, damage.PHYSICAL):deal(champ, target)
target:effect(airborne.new(1.25))
end

function champ.abilities.w:use(context, cast)
champ:effect(shield.new(6.0, 250.0):on_finish(function()
self.proj = aoe:new(self, { colliders = context.enemies,
size = 500,
color = { 0.6,0.4,0.4,0.9 },
follow = champ,
deploy_time = 0.1,
})
context.spawn( self.proj
)
end))
end

function champ.abilities.w:hit(target)
damage:new(250, damage.MAGIC):deal(champ, target)
end

function champ.abilities.r:use(context, cast)
local persist_time = cast.mag / 1050
champ:effect(dash.new(1050, cast.pos))
champ:effect(unstoppable.new(persist_time))
self.proj = aoe:new(self, { colliders = context.enemies,
size = 340,
color = { 0.6,0.4,0.4 },
persist_time = persist_time,
tick = 0.1,
follow = champ,
re_hit = false,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(450, damage.PHYSICAL):deal(champ, target)
target:effect(airborne.new(1.0))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 400
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 400+100
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return sion