local big_cast = require("abilities.big")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local shield = require("effects.shield")
local slow = require("effects.slow")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local viktor = {}

-- Constructor
function viktor.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2000,
    armor = 75,
    mr = 45,
    ms = 335,
    sprite = 'viktor.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.2, 525, 90, { 0.7,0.7,0.7 }),
    q = ranged_cast.new(4.8, 600),
    w = splash_cast.new(12.4, 800, 300),
    e = ranged_cast.new(7.6, 550),
    r = big_cast.new(76.2, 700, 400),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 100,
speed = 2000,
color = { 0.7,0.7,0.7 },
range = 600,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(200, damage.MAGIC):deal(champ, target)
target:effect(shield.new(2.0, 242.0))
end

function champ.abilities.w:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.7,0.7,0.7 },
deploy_time = 0.1,
at = cast.pos,
persist_time = 1,
})
self.proj.after = function ()
for _,enemy in pairs ( distances.in_range_list ( self.proj , context.enemies , 300 / 2 )) do
enemy:effect(stun.new(1.0))
end
end
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
target:effect(slow.new(1.0, 0.3))
end

function champ.abilities.e:use(context, cast)
local dir = cast.dir * 200 / 2
local cpos = cast.pos - dir
local tpos = cast.pos + dir
self.proj = missile.new(self, { dir = dir,
colliders = context.enemies,
size = 80,
speed = 1500,
color = { 0.7,0.7,0.7 },
range = 550,
from = cpos,
to = tpos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(330, damage.MAGIC):deal(champ, target)
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 400,
color = { 0.7,0.7,0.7 },
persist_time = 6,
tick = 0.5,
at = cast.pos,
follow = context.closest_enemy,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(155, damage.MAGIC):deal(champ, target)
end

function champ.behaviour(ready, context)
champ.range = 600+100
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return viktor