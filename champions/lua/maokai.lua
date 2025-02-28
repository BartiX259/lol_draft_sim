local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local dash = require("effects.dash")
local pull = require("effects.pull")
local root = require("effects.root")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local maokai = {}

-- Constructor
function maokai.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2450,
    armor = 135,
    mr = 85,
    ms = 345,
    sprite = 'maokai.jpg',
  })

  champ.abilities = {
    q = ranged_cast.new(6, 200),
    w = ranged_cast.new(12, 525),
    r = splash_cast.new(120, 3000, 600),
  }
function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.2,0.6,0.2 },
follow = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(300, damage.MAGIC):deal(champ, target)
local dir = ( target.pos - self.proj.pos ):normalize () * 100
local pos = target.pos + dir
target:effect(pull.new(1000.0, pos))
end

function champ.abilities.w:use(context, cast)
champ:effect(dash.new(1500.0, cast.target):on_finish(function()
cast.target:effect(root.new(1.5))
end))
end

function champ.abilities.w:hit(target)
damage:new(250, damage.MAGIC):deal(champ, target)
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 600,
speed = 500,
color = { 0.2,0.6,0.2 },
range = 3000,
from = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(500, damage.MAGIC):deal(champ, target)
target:effect(root.new(2.5))
end

function champ.behaviour(ready, context)
if ready.w then
champ.range = 525
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 200+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return maokai