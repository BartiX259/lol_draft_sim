local big_cast = require("abilities.big")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local dash = require("effects.dash")
local pull = require("effects.pull")
local root = require("effects.root")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local maokai = {}

-- Constructor
function maokai.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2523.00,
    armor = 127.40,
    mr = 121.60,
    ms = 380,
    sprite = 'maokai.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.3, 125, 88),
    q = ranged_cast.new(3.4, 160),
    w = ranged_cast.new(6.65, 525),
    r = big_cast.new(95.66, 3000, 240),
  }

function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 320,
color = { 0.2,0.6,0.2 },
follow = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(355, damage.MAGIC):deal(champ, target)
local dir = ( target.pos - self.proj.pos ):normalize () * 100
local pos = target.pos + dir
champ :heal ( 75 )
target:effect(pull.new(1000, pos))
end

function champ.abilities.w:use(context, cast)
champ:effect(dash.new(1500, cast.target):on_finish(function()
cast.target:effect(root.new(1.4))
end))
end

function champ.abilities.w:hit(target)
damage:new(276, damage.MAGIC):deal(champ, target)
end

function champ.abilities.r:precast(context, cast)
if cast.target :has_effect ( "root" ) then
return nil
end
return cast
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 240,
speed = 750,
color = { 0.2,0.6,0.2 },
range = 3000,
from = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(455, damage.MAGIC):deal(champ, target)
target:effect(root.new(2.25))
end

function champ.behaviour(ready, context)
if context.closest_dist < 200 then
champ.range = 125
champ.target = context.closest_enemy
elseif ready.w then
champ.range = 525
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 160+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return maokai