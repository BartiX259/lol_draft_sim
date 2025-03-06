local buff_cast = require("abilities.buff")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local root = require("effects.root")
local shield = require("effects.shield")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local ivern = {}

-- Constructor
function ivern.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2418,
    armor = 63.4,
    mr = 45.6,
    ms = 380,
    sprite = 'ivern.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(0.95, 475, 164, { 0.2,0.8,0.4 }),
    q = ranged_cast.new(5.3, 1150),
    e = buff_cast.new(4.1, 750),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 160,
speed = 1300,
color = { 0.2,0.8,0.4 },
range = 1150,
stop_on_hit = true,
from = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(302, damage.MAGIC):deal(champ, target)
target:effect(root.new(2.0))
end

function champ.abilities.e:use(context, cast)
cast.target:effect(shield.new(2.0, 437.8))
self.proj = aoe:new(self, { colliders = context.enemies,
size = 500,
color = { 0.2,0.8,0.4 },
deploy_time = 0.1,
persist_time = 0.2,
follow = cast.target,
})
context.delay(2, function() context.spawn( self.proj
)
end)
end

function champ.abilities.e:hit(target)
damage:new(252, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.0, 0.6))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 1150-50
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 1150+150
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return ivern