local always_cast = require("abilities.always")
local big_cast = require("abilities.big")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local rumble = {}

-- Constructor
function rumble.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2165,
    armor = 62.4,
    mr = 46.6,
    ms = 375,
    sprite = 'rumble.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.5, 125, 102.4),
    q = ranged_cast.new(5.5, 600),
    q_pos = always_cast.new(0),
    e = ranged_cast.new(6.7, 950),
    r = big_cast.new(64, 1700, 200),
  }
champ.abilities.q_pos:join(champ.abilities.q)

function champ.abilities.q:use(context, cast)
self.active = true
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.9,0.4,0.1 },
persist_time = 3,
tick = 0.25,
at = champ,
}):on_finish(function() self.active = false
end)
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(32, damage.MAGIC):deal(champ, target)
end

function champ.abilities.q_pos:precast(context, cast)
champ.abilities.q.proj.pos = champ.pos + ( context.closest_enemy.pos - champ.pos ):normalize () * 140
return nil
end

function champ.abilities.q_pos:use(context, cast)
end

function champ.abilities.e:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 2000,
color = { 0.9,0.4,0.1 },
range = 950,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(235, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.0, 0.35))
end

function champ.abilities.r:precast(context, cast)
local longest_mag = 1
local t1 = nil
local t2 = nil
for _,e1 in pairs ( distances.in_range_list ( cast , context.enemies , 1000 )) do
for _,e2 in pairs ( distances.in_range_list ( cast , context.enemies , 1000 )) do
local mag = e1.pos :distance ( e2.pos )
if mag > longest_mag then
longest_mag = mag
t1 = e1
t2 = e2
end
end
end
if t1 ~= nil and t2 ~= nil then
local dir = t2.pos - t1.pos
if dir :mag () > 0.01 then
cast.pos = t1.pos
cast.dir = dir :normalize ()
end
else
cast.pos = cast.pos - cast.dir * 500
end
return cast
end

function champ.abilities.r:use(context, cast)
local line_start = cast.pos
local line_end = cast.pos + cast.dir
local num_aoes = 6
local step = ( line_end - line_start ):normalize () * ( 200 )
local hit_cols = {}
for i = 0 , num_aoes - 1 do
local aoe_pos = line_start + step * i
local proj = aoe:new(self, { colliders = context.enemies,
size = 200,
color = { 0.9,0.4,0.1 },
deploy_time = 0.75,
persist_time = 4.5,
hit_cols = hit_cols,
tick = 0.5,
at = aoe_pos,
})
context.spawn( proj
)
end
end

function champ.abilities.r:hit(target)
damage:new(148, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.0, 0.35))
end

function champ.behaviour(ready, context)
if champ.abilities.q.active and context.closest_dist < 600 then
champ.range = 125
champ.target = context.closest_enemy
elseif ready.e then
champ.range = 950
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 950+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return rumble