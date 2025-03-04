local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local pull = require("effects.pull")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local rell = {}

-- Constructor
function rell.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2678,
    armor = 146.4,
    mr = 84.6,
    ms = 385,
    sprite = 'rell.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.2, 175, 91),
    q = ranged_cast.new(4.18, 400),
    w = splash_cast.new(6.00, 450, 280),
    r = ranged_cast.new(72.73, 450),
  }

function champ.abilities.q:precast(context, cast)
if cast.target :has_effect ( "root" ) then
return nil
end
return cast
end

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 150,
speed = 2000,
color = { 0.7,0.7,0.7 },
range = 400,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(280, damage.MAGIC):deal(champ, target)
target:effect(stun.new(1.0))
end

function champ.abilities.w:use(context, cast)
local speed = cast.mag / 0.4
champ:effect(dash.new(speed, cast.pos))
self.proj = aoe:new(self, { colliders = context.enemies,
size = 280,
color = { 0.7,0.7,0.7 },
deploy_time = 0.4,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
damage:new(200, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.0))
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 450,
color = { 0.7,0.7,0.7 },
follow = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(235, damage.MAGIC):deal(champ, target)
target:effect(pull.new(200, champ))
target:effect(airborne.new(0.6):on_finish(function()
target :del_effect ( "pull" )
end))
end

function champ.behaviour(ready, context)
champ.range = 450+150
champ:change_movement(movement.PEEL)
end

  return champ
end

return rell