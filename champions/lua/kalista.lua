local always_cast = require("abilities.always")
local important_cast = require("abilities.important")
local ranged_cast = require("abilities.ranged")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local slow = require("effects.slow")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local kalista = {}

-- Constructor
function kalista.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2048,
    armor = 72.4,
    mr = 65.6,
    ms = 385,
    sprite = 'kalista.jpg',
  })

  champ.abilities = {
    dash = ability:new(0),
    aa = ranged_cast.new(0.77, 525),
    rend_stack_timers = always_cast.new(),
    q = ranged_cast.new(5.93, 1200),
    e = ability:new(5.93),
    r = important_cast.new(140, 1500),
  }
function champ.abilities.dash:cast(context)
if champ.dash then
return true
end
end

function champ.abilities.dash:use(context, cast)
champ.dash = false
local dpos = distances.dash_pos ( context , 200 , 525 )
if not dpos then
dpos = champ.pos + ( context.closest_enemy.pos - champ.pos ):normalize () * 200
end
champ:effect(dash.new(1500, dpos))
end

function champ.abilities.aa:start()
champ.rend_stacks = {}
champ.timers = {}
end

function champ.abilities.aa:use(context, cast)
champ.dash = true
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 50,
speed = 1500,
color = { 0.2,0.8,0.7 },
range = 525,
from = champ.pos,
to = cast.target,
})
context.spawn( self.proj
)
end

function champ.abilities.aa:hit(target)
damage:new(239, damage.PHYSICAL):deal(champ, target)
if champ.rend_stacks [ target ] == nil then
champ.rend_stacks [ target ] = 0
end
champ.timers [ target ] = 4
champ.rend_stacks [ target ] = champ.rend_stacks [ target ] + 1
end

function champ.abilities.rend_stack_timers:use(context, cast)
for key,timer in pairs ( champ.timers ) do
champ.timers [ key ] = timer - context.dt
if champ.timers [ key ] <= 0 then
champ.rend_stacks [ key ] = nil
champ.timers [ key ] = nil
end
end
end

function champ.abilities.q:use(context, cast)
champ.dash = true
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 80,
speed = 2400,
color = { 0.2,0.8,0.7 },
range = 1200,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(531, damage.PHYSICAL):deal(champ, target)
if champ.rend_stacks [ target ] == nil then
champ.rend_stacks [ target ] = 0
end
champ.timers [ target ] = 4
champ.rend_stacks [ target ] = champ.rend_stacks [ target ] + 1
end

function champ.abilities.e:cast(context)
for champ,count in pairs ( champ.rend_stacks ) do
if champ.timers ~= nil and champ.timers [ champ ] ~= nil and champ.timers [ champ ] < 1 and count > 5 then
return true
end
local dmg = 217 + ( 41 * count )
if dmg > champ.health + 100 then
return true
end
end
return nil
end

function champ.abilities.e:use(context, cast)
local cast = {}
for champ,count in pairs ( champ.rend_stacks ) do
self.dmg = 217 + ( 41 * count )
cast.target = champ
damage:new(self.dmg, damage.PHYSICAL):deal(champ, cast.target)
cast.target:effect(slow.new(2.0, 0.5))
end
champ.rend_stacks = {}
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 300,
speed = 1500,
color = { 0.2,0.8,0.7 },
range = 1500,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(100, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.5))
end

function champ.behaviour(ready, context)
champ.range = 525
champ:change_movement(movement.KITE)
end

  return champ
end

return kalista