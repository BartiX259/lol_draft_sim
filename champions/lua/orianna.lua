local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local pull = require("effects.pull")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local orianna = {}

-- Constructor
function orianna.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1905,
    armor = 70.4,
    mr = 41.6,
    ms = 370,
    sprite = 'orianna.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1, 525, 113, { 0.3,0.5,0.8 }),
    q = splash_cast.new(2.5, 825, 175),
    w = ability:new(5.83),
    r = ability:new(66.66),
  }

function champ.abilities.q:use(context, cast)
local cast_pos = cast.pos
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 175,
speed = 1400,
color = { 0.3,0.5,0.8 },
range = 825,
from = champ.pos,
to = cast_pos,
})
self.proj.next = aoe:new(self, { colliders = nil,
size = 175,
color = { 0.3,0.5,0.8 },
persist_time = 1,
at = cast_pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(290, damage.MAGIC):deal(champ, target)
end

function champ.abilities.w:cast(context)
return champ.abilities.q.proj and distances.in_range ( champ.abilities.q.proj , context.enemies , 225 / 2 + 30 ) >= 1
end

function champ.abilities.w:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 225,
color = { 0.3,0.5,0.8 },
at = champ.abilities.q.proj,
follow = champ.abilities.q.proj,
soft_follow = true,
})
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
damage:new(410, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.0, 0.2))
end

function champ.abilities.r:cast(context)
return champ.abilities.q.proj and distances.in_range ( champ.abilities.q.proj , context.enemies , 415 / 2 ) >= math.clamp ( # context.enemies - 1 , 1 , 3 )
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 415,
color = { 0.3,0.5,0.8,0.7 },
deploy_time = 0.2,
at = champ.abilities.q.proj,
follow = champ.abilities.q.proj,
soft_follow = true,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(590, damage.MAGIC):deal(champ, target)
target:effect(pull.new(1200.0, self.proj))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 825-50
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 825+200
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return orianna