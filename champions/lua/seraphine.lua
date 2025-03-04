local buff_cast = require("abilities.buff")
local important_cast = require("abilities.important")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local charm = require("effects.charm")
local shield = require("effects.shield")
local slow = require("effects.slow")
local speed = require("effects.speed")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local seraphine = {}

-- Constructor
function seraphine.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2050,
    armor = 76.4,
    mr = 45.6,
    ms = 380,
    sprite = 'seraphine.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.0, 625, 140, { 0.9,0.6,0.8 }),
    q = splash_cast.new(4.6, 900, 300),
    w = buff_cast.new(13.8, 400),
    e = ranged_cast.new(6.9, 1200),
    r = important_cast.new(108, 1600),
  }

function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.9,0.6,0.8 },
deploy_time = 0.6,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(200, damage.MAGIC):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
local size = 400 * 2
self.proj = aoe:new(self, { colliders = context.allies,
size = size,
color = { 0.9,0.6,0.8,0.9 },
deploy_time = 0.15,
follow = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
target:effect(shield.new(2.5, 190.0))
target:effect(speed.new(5.0, 0.1))
end

function champ.abilities.e:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 1400,
color = { 0.9,0.6,0.8 },
range = 1200,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(150, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.25, 0.5))
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 280,
speed = 1600,
color = { 0.9,0.6,0.8 },
range = 1600,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(240, damage.MAGIC):deal(champ, target)
target:effect(charm.new(1.75, 200, champ))
end

function champ.behaviour(ready, context)
champ.range = 900
champ:change_movement(movement.PEEL)
end

  return champ
end

return seraphine