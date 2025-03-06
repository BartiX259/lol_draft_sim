local none_cast = require("abilities.none")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local pull = require("effects.pull")
local slow = require("effects.slow")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local taliyah = {}

-- Constructor
function taliyah.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1890,
    armor = 67.4,
    mr = 45.6,
    ms = 380,
    sprite = 'taliyah.jpg',
    damage_split = { 0.0, 1.0, 0.0 }
  })
  champ.abilities = {
    aa = ranged_aa_cast.new(1.1, 525, 98, { 0.7,0.5,0.3 }),
    q = ranged_cast.new(4.5, 1000),
    w = splash_cast.new(9.8, 900, 200),
    e = ranged_cast.new(12.8, 500),
    e_ticks = none_cast.new(),
  }

function champ.abilities.q:use(context, cast)
local timings = { 0 , 0.4 , 0.7 , 0.9 , 1.1 }
local num_rocks = # timings
local spread_angle = 5
for _,i in pairs ( timings ) do
local angle_offset = ( i - ( num_rocks + 1 ) / 2 ) * ( spread_angle / ( num_rocks - 1 ))
local dir = cast.dir :rotate ( math.random (- 1 , 1 ) * math.rad ( angle_offset ))
local proj = missile.new(self, { dir = dir,
colliders = context.enemies,
size = 100,
speed = 1500,
color = { 0.7,0.5,0.3 },
range = 1000,
stop_on_hit = true,
from = champ,
})
context.delay(i, function() context.spawn( proj
)
end)
end
end

function champ.abilities.q:hit(target)
damage:new(205, damage.MAGIC):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 200,
color = { 0.7,0.5,0.3 },
deploy_time = 0.8,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
local knockup_dir = ( target.pos - self.proj.pos ):normalize ()
local knockup_dist = 300
local target_pos = target.pos + knockup_dir * knockup_dist
target:effect(pull.new(1200, target_pos))
end

function champ.abilities.e:use(context, cast)
local num_rows = 6
local num_boulders_per_row = 4
local boulder_spacing = 110
self.projs = {}
local hit_cols = {}
for i = 0 , num_rows - 1 do
local row_offset = cast.dir * ( i * boulder_spacing )
for _,dir in pairs ( cast.dir :perp ( num_boulders_per_row )) do
local boulder_pos = champ.pos + row_offset + dir * boulder_spacing
local proj = aoe:new(self, { colliders = context.enemies,
size = 70,
color = { 0.7,0.5,0.3 },
deploy_time = 0.25,
hit_cols = hit_cols,
at = boulder_pos,
persist_time = 0,
})
table.insert ( self.projs , proj )
local del = i * 0.1
context.delay(del, function() context.spawn( proj
)
end)
end
end
champ.abilities.e_ticks:with_e(context, cast)
end

function champ.abilities.e:hit(target)
damage:new(330, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.0, 0.2))
end

function champ.abilities.e_ticks:with_e(context, cast)
local hit_cols = {}
for _,proj in pairs ( champ.abilities.e.projs ) do
proj.next = aoe:new(self, { colliders = context.enemies,
size = 70,
color = { 0.7,0.5,0.3 },
deploy_time = 0,
persist_time = 4,
hit_cols = hit_cols,
tick = 0,
})
end
end

function champ.abilities.e_ticks:hit(target)
if target :has_effect ( "pull" ) then
target :del_effect ( "pull" )
target:effect(stun.new(0.75))
damage:new(150, damage.MAGIC):deal(champ, target)
end
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 1000
champ:change_movement(movement.PASSIVE)
elseif ready.w then
champ.range = 900
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 1000+100
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return taliyah