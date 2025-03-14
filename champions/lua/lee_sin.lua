local buff_cast = require("abilities.buff")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local dash = require("effects.dash")
local pull = require("effects.pull")
local shield = require("effects.shield")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local lee_sin = {}

-- Constructor
function lee_sin.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2541,
    armor = 119.8,
    mr = 78.6,
    ms = 385,
    sprite = 'lee_sin.jpg',
    damage_split = { 1.0, 0.0, 0.0 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(0.8, 125, 237.4),
    q = ranged_cast.new(4.4, 1200),
    w = buff_cast.new(6.2, 700),
    r = ability:new(68),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 1800,
color = { 0.4,0.6,0.8 },
range = 1200,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(371.5, damage.PHYSICAL):deal(champ, target)
champ:effect(dash.new(1695, target))
end

function champ.abilities.w:use(context, cast)
if cast.target ~= champ then
champ:effect(dash.new(1695, cast.pos))
champ:effect(shield.new(2.0, 250.0))
end
cast.target:effect(shield.new(2.0, 250.0))
end

function champ.abilities.r:cast(context)
local lowest = math.huge
local target
for _,champ in pairs ( distances.in_range_list(champ, context.enemies, 425) ) do
if champ.health < lowest then
lowest = champ.health
target = champ
end
end
if target == nil then
return nil
end
if lowest < 1600 then
return {
target = target ,
pos = target.pos
}
end
return nil
end

function champ.abilities.r:use(context, cast)
champ:effect(dash.new(1600, cast.target):on_finish(function()
local kick_dir = ( context.allies_avg_pos - cast.pos ):normalize ()
local kick_pos = cast.pos + kick_dir * 800
cast.target:effect(pull.new(1000, kick_pos))
damage:new(805, damage.PHYSICAL):deal(champ, cast.target)
end))
end

function champ.behaviour(ready, context)
if context.closest_dist < 125 + 100 then
champ.range = 125
champ.target = context.closest_enemy
else
champ.range = 1200+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return lee_sin