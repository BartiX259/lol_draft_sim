local big_cast = require("abilities.big")
local none_cast = require("abilities.none")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local root = require("effects.root")
local shield = require("effects.shield")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local senna = {}

-- Constructor
function senna.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1981,
    armor = 65,
    mr = 46.9,
    ms = 375,
    sprite = 'senna.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.4, 630, 230, { 0.6,0.7,0.8 }),
    q = ranged_cast.new(5.4, 1000),
    w = ranged_cast.new(9.3, 900),
    r = big_cast.new(81, 2000, 200),
    r_shield = none_cast.new(),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 100,
speed = 1600,
color = { 0.6,0.7,0.8 },
range = 1000,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(263, damage.PHYSICAL):deal(champ, target)
champ :heal ( 30 )
end

function champ.abilities.w:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 1000,
color = { 0.6,0.7,0.8 },
range = 900,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
damage:new(170, damage.PHYSICAL):deal(champ, target)
target:effect(root.new(1.75))
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 200,
speed = 1800,
color = { 0.6,0.7,0.8 },
range = 2000,
from = champ.pos,
})
context.spawn( self.proj
)
champ.abilities.r_shield:with_r(context, cast)
end

function champ.abilities.r:hit(target)
damage:new(487, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.r_shield:with_r(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.allies,
size = 500,
speed = 1800,
color = { 0.6,0.7,0.8,0.8 },
range = 2000,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r_shield:hit(target)
target:effect(shield.new(2.0, 260.0))
end

function champ.behaviour(ready, context)
champ.range = 630
champ:change_movement(movement.KITE)
end

  return champ
end

return senna