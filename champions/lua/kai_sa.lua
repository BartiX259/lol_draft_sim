local important_cast = require("abilities.important")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local dash = require("effects.dash")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local kai_sa = {}

-- Constructor
function kai_sa.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1864,
    armor = 75.4,
    mr = 45.6,
    ms = 380,
    sprite = 'kai_sa.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(0.9, 525, 190.2, { 0.7,0.3,0.9 }),
    q = ranged_cast.new(6.2, 600),
    w = ranged_cast.new(10, 3000),
    r = important_cast.new(100, 2500),
  }

function champ.abilities.q:use(context, cast)
local target = context.closest_enemy
if target == nil then return end
local angle_increment = 360 / 6
for i = 1 , 6 do
local angle = ( i - 1 ) * angle_increment
local dir = ( target.pos - champ.pos ):rotate ( math.rad ( angle )):normalize ()
local proj_pos = champ.pos + dir * 50
local proj = missile.new(self, { dir = dir,
colliders = context.enemies,
size = 80,
speed = 1200,
color = { 0.7,0.3,0.9 },
range = nil,
from = proj_pos,
to = target,
})
local del = i * 0.05
context.delay(del, function() context.spawn( proj
)
end)
end
end

function champ.abilities.q:hit(target)
damage:new(175, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 200,
speed = 1750,
color = { 0.7,0.3,0.9 },
range = 3000,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
damage:new(352, damage.MAGIC):deal(champ, target)
end

function champ.abilities.r:precast(context, cast)
if cast.target :has_effect ( "root" ) then
return cast
end
return nil
end

function champ.abilities.r:use(context, cast)
local dash_dir = ( cast.pos - champ.pos ):normalize ()
local dash_dest = cast.pos + dash_dir * 500
champ:effect(dash.new(2000, dash_dest))
end

function champ.behaviour(ready, context)
champ.range = 525
champ:change_movement(movement.KITE)
end

  return champ
end

return kai_sa