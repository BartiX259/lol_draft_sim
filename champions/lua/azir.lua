local dash_cast = require("abilities.dash")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local dash = require("effects.dash")
local pull = require("effects.pull")
local shield = require("effects.shield")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local azir = {}

-- Constructor
function azir.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2139,
    armor = 85,
    mr = 45.6,
    ms = 380,
    sprite = 'azir.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.509, 525, 98, { 0.9,0.8,0.3 }),
    q = ranged_cast.new(5.2, 740),
    w = ranged_cast.new(4, 740),
    e = dash_cast.new(10.67, 600, 525),
    r = ranged_cast.new(70, 150),
  }

function champ.abilities.q:precast(context, cast)
if # champ.abilities.w.projs == 0 then
return nil
end
return cast
end

function champ.abilities.q:use(context, cast)
for _,soldier in pairs ( champ.abilities.w.projs ) do
local dash_pos = cast.pos + ( soldier.pos - cast.pos ):normalize () * 100
local proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 320,
speed = 1800,
color = { 0.9,0.8,0.3 },
range = 740,
from = soldier.pos,
to = dash_pos,
})
soldier.follow = proj
context.spawn( proj
)
end
end

function champ.abilities.q:hit(target)
damage:new(275, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.0, 0.25))
end

function champ.abilities.w:start()
self.projs = {}
end

function champ.abilities.w:use(context, cast)
local cast_pos = champ.pos + cast.dir * math.min ( cast.mag , 525 )
local proj = aoe:new(self, { colliders = nil,
size = 320,
color = { 0.9,0.8,0.3 },
tick = 1.5,
at = cast_pos,
persist_time = 9,
soft_follow = true,
})
table.insert ( self.projs , proj )
context.delay(9, function()
proj.despawn = true
for i,v in pairs ( self.projs ) do
if v == proj then
table.remove ( self.projs , i )
break
end
end
end)
context.spawn( proj
)
end

function champ.abilities.w:hit(target)
damage:new(190, damage.MAGIC):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
champ:effect(dash.new(1300, cast.pos))
champ:effect(shield.new(1.5, 200.0))
end

function champ.abilities.r:use(context, cast)
local hit_cols = {}
local wall_start_pos = champ.pos - cast.dir * 100
for _,dir in pairs ( cast.dir :perp ( 7 )) do
local soldier_pos = wall_start_pos + dir * 100
local cast_pos = soldier_pos + cast.dir * 600
local proj = missile.new(self, { dir = dir,
colliders = context.enemies,
size = 120,
speed = 1400,
color = { 0.9,0.8,0.3 },
range = 150,
hit_cols = hit_cols,
from = soldier_pos,
to = cast_pos,
})
context.spawn( proj
)
end
end

function champ.abilities.r:hit(target)
damage:new(475, damage.MAGIC):deal(champ, target)
local push_dir = ( target.pos - champ.pos ):normalize ()
local push_dest = target.pos + push_dir * 600
target:effect(pull.new(1400, push_dest))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 740
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 740+100
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return azir