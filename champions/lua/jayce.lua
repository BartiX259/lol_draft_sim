local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local dash = require("effects.dash")
local pull = require("effects.pull")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local jayce = {}

-- Constructor
function jayce.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2099,
    armor = 82,
    mr = 45.6,
    ms = 380,
    sprite = 'jayce.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.25, 500, 240, { 0.3,0.5,0.8 }),
    q_ranged = ranged_cast.new(6.1, 1550),
    e = ranged_cast.new(8.4, 240),
    q_melee = ranged_cast.new(4.5, 600),
  }

function champ.abilities.q_ranged:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 220,
speed = 2350,
color = { 0.3,0.5,0.8 },
range = 1550,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q_ranged:hit(target)
damage:new(546, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
local target_pos = cast.pos + cast.dir * 400
cast.target:effect(pull.new(1200, target_pos))
damage:new(440, damage.MAGIC):deal(champ, cast.target)
end

function champ.abilities.q_melee:use(context, cast)
champ:effect(dash.new(1800, cast.pos))
self.proj = aoe:new(self, { colliders = context.enemies,
size = 200,
color = { 0.8,0.7,0.1 },
deploy_time = 0.25,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q_melee:hit(target)
damage:new(503, damage.PHYSICAL):deal(champ, target)
target:effect(slow.new(2.0, 0.5))
end

function champ.behaviour(ready, context)
champ.range = 1550
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return jayce