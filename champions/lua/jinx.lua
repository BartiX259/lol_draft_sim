local important_cast = require("abilities.important")
local ranged_cast = require("abilities.ranged")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local jinx = {}

-- Constructor
function jinx.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1900,
    armor = 62.4,
    mr = 45.6,
    ms = 370,
    sprite = 'jinx.jpg',
    damage_split = { 1.0, 0.0, 0.0 }
  })
  champ.abilities = {
    aa = ranged_cast.new(0.845, 625),
    w = ranged_cast.new(5, 1500),
    r = important_cast.new(65, 5000),
  }
function champ.abilities.aa:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 80,
speed = 1800,
color = { 0.9,0.5,0.6 },
range = nil,
from = champ.pos,
to = cast.target,
})
local hit_cols = { [ cast.target ] = true }
self.proj.next = aoe:new(self, { colliders = context.enemies,
size = 200,
color = { 0.9,0.5,0.6 },
hit_cols = hit_cols,
})
context.spawn( self.proj
)
end

function champ.abilities.aa:hit(target)
damage:new(180, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 3300,
color = { 0.9,0.5,0.6 },
range = 1500,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
damage:new(383, damage.PHYSICAL):deal(champ, target)
target:effect(slow.new(2.0, 0.6))
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 250,
speed = 2200,
color = { 0.9,0.4,0.5 },
range = 5000,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(582, damage.PHYSICAL):deal(champ, target)
end

function champ.behaviour(ready, context)
champ.range = 625
champ:change_movement(movement.KITE)
end

  return champ
end

return jinx