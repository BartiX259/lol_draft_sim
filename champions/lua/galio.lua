local melee_aa_cast = require("abilities.melee_aa")
local none_cast = require("abilities.none")
local ranged_cast = require("abilities.ranged")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local fly = require("effects.fly")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local galio = {}

-- Constructor
function galio.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2544,
    armor = 75.4,
    mr = 96.6,
    ms = 385,
    sprite = 'galio.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.2, 150, 100),
    q = ranged_cast.new(6.3, 825),
    q_tick = none_cast.new(),
    w = ranged_cast.new(12.6, 350),
    e = ranged_cast.new(6.3, 650),
    r = ability:new(144),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 150,
speed = 1400,
color = { 0.7,0.7,1.0 },
range = 825,
from = champ.pos,
to = cast.pos,
})
context.spawn( self.proj
)
self.proj.after = function() champ.abilities.q_tick:after_q(context, cast) end
end

function champ.abilities.q:hit(target)
damage:new(250, damage.MAGIC):deal(champ, target)
end

function champ.abilities.q_tick:after_q(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 150,
color = { 0.7,0.7,1.0 },
persist_time = 2,
tick = 0.5,
at = champ.abilities.q.proj.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q_tick:hit(target)
damage:new(70, damage.MAGIC):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 350,
color = { 0.7,0.7,1.0 },
deploy_time = 1,
follow = champ,
})
self.active = true
context.delay(1, function() self.active = false
end)
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
target:effect(stun.new(1.5))
damage:new(150, damage.MAGIC):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 320,
color = { 0.7,0.7,1.0 },
follow = champ,
tick = 0,
})
context.spawn( self.proj
)
champ:effect(dash.new(2300, cast.pos))
end

function champ.abilities.e:hit(target)
self.proj.despawn = true
champ :del_effect (" dash ")
damage:new(240, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(0.75))
end

function champ.abilities.r:cast(context)
for _,ally in pairs ( distances.in_range_list ( champ , context.allies , 5500 )) do
if distances.in_range ( ally , context.enemies , 650 / 4 ) >= math.clamp ( # context.enemies - 1 , 1 , 3 ) then
return { pos = ally.pos }
end
end
end

function champ.abilities.r:use(context, cast)
local ch = 2 / 2
champ:effect(fly.new(2, ch):on_finish(function()
champ.pos = cast.pos
end))
self.proj = aoe:new(self, { colliders = context.enemies,
size = 650,
color = { 0.7,0.7,1.0 },
deploy_time = 2,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(320, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.0))
end

function champ.behaviour(ready, context)
if champ.abilities.w.active or ready.w and context.closest_dist < 350 + 150 then
champ.range = 350
champ.target = context.closest_enemy
else
champ.range = 825
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return galio