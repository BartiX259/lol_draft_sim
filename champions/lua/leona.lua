local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local dash = require("effects.dash")
local root = require("effects.root")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local leona = {}

-- Constructor
function leona.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2558,
    armor = 146,
    mr = 87,
    ms = 395,
    sprite = 'leona.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.19, 125, 116),
    q = melee_aa_cast.new(4.06, 125, 110),
    e = ranged_cast.new(4.87, 900),
    r = splash_cast.new(60.94, 1200, 325),
  }


function champ.abilities.e:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 140,
speed = 2000,
color = { 1,0.8,0.2 },
range = 900,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(210, damage.MAGIC):deal(champ, target)
target:effect(root.new(0.5))
champ:effect(dash.new(1500.0, target.pos))
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 325,
color = { 1,0.8,0.2 },
deploy_time = 0.625,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(225, damage.MAGIC):deal(champ, target)
target:effect(stun.new(1.75))
end

function champ.behaviour(ready, context)
if ready.e then
champ.range = 900
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 125+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return leona