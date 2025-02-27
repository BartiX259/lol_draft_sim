local melee_aa = require("abilities.melee_aa")
local none = require("abilities.none")
local splash = require("abilities.splash")
local airborne = require("effects.airborne")
local pull = require("effects.pull")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local ornn = {}

-- Constructor
function ornn.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2518,
    armor = 270,
    mr = 117,
    ms = 380,
    sprite = 'ornn.jpg',
  })

  champ.abilities = {
    aa = melee_aa.new(1.2, 175, 111),
    e = splash.new(12, 800, 360),
    r = splash.new(100, 2500, 340),
    r_recast = none.new(),
  }

function champ.abilities.e:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 360,
color = { 0.8,0.4,0.2 },
deploy_time = 0.35,
follow = champ,
})
context.spawn( self.proj
)
champ:effect(pull.new(1600.0, cast.pos))
end

function champ.abilities.e:hit(target)
damage:new(348, damage.PHYSICAL):deal(champ, target)
target:effect(airborne.new(1.25))
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 340,
speed = 1200,
color = { 0.8,0.4,0.2 },
range = 2500,
from = cast.pos,
to = champ,
})
context.spawn( self.proj
)
self.proj.after = function() champ.abilities.r_recast:after_r(context, cast) end
end

function champ.abilities.r:hit(target)
damage:new(175, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.0, 0.5))
end

function champ.abilities.r_recast:after_r(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 340,
speed = 1900,
color = { 0.8,0.4,0.2 },
from = champ.abilities.r.proj,
to = context.closest_enemy.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r_recast:hit(target)
damage:new(350, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.0))
end

function champ.behaviour(ready, context)
if ready.e then
champ.range = 800
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 800+250
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return ornn