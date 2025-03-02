local important_cast = require("abilities.important")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local pull = require("effects.pull")
local root = require("effects.root")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local nautilus = {}

-- Constructor
function nautilus.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2846,
    armor = 168.4,
    mr = 136.6,
    ms = 385,
    sprite = 'nautilus.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1, 175, 101),
    q = ranged_cast.new(6.33, 1122),
    r = important_cast.new(83.33, 925),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 180,
speed = 2000,
color = { 0.3,0.9,0.9 },
range = 1122,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(250, damage.MAGIC):deal(champ, target)
local distance = ( target.pos - champ.pos ):mag ()
local pull_direction = ( target.pos - champ.pos ):normalize ()
local pull_target = target.pos - pull_direction * ( distance * ( 1 - 0.5 ))
local pull_self = champ.pos + pull_direction * ( distance * 0.5 )
target:effect(pull.new(1300, pull_target):on_finish(function()
target:effect(root.new(1.3))
end))
champ:effect(dash.new(1300, pull_self))
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 300,
speed = 275,
color = { 0.3,0.9,0.9 },
range = 925,
from = champ.pos,
to = cast.target,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(275, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.5))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 1122-50
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 1122+150
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return nautilus