local buff_cast = require("abilities.buff")
local ranged_cast = require("abilities.ranged")
local invulnerable = require("effects.invulnerable")
local slow = require("effects.slow")
local speed = require("effects.speed")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local kayle = {}

-- Constructor
function kayle.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2024,
    armor = 61.4,
    mr = 47.6,
    ms = 380,
    sprite = 'kayle.jpg',
    damage_split = { 0.0, 1.0, 0.0 }
  })
  champ.abilities = {
    aa = ranged_cast.new(0.8, 525),
    q = ranged_cast.new(7.27, 900),
    w = buff_cast.new(13.64, 500),
    r = ability:new(109.09),
  }
function champ.abilities.aa:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 80,
speed = 1800,
color = { 0.9,0.9,0.1 },
range = nil,
from = champ.pos,
to = cast.target,
})
local hit_cols = { [ cast.target ] = true }
self.proj.next = aoe:new(self, { colliders = context.enemies,
size = 200,
color = { 0.9,0.9,0.1 },
hit_cols = hit_cols,
})
context.spawn( self.proj
)
end

function champ.abilities.aa:hit(target)
damage:new(180, damage.MAGIC):deal(champ, target)
end

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 1600,
color = { 0.9,0.9,0.1 },
range = 900,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(320, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.0, 0.5))
end

function champ.abilities.w:use(context, cast)
if cast.target ~= champ then
cast.target :heal ( 205 )
cast.target:effect(speed.new(2.0, 0.56))
end
champ :heal ( 205 )
champ:effect(speed.new(2.0, 0.56))
end

function champ.abilities.r:cast(context)
for _,ally in pairs ( distances.in_range_list ( champ , context.allies , 400 )) do
if ally.health < 500 then
return { target = ally }
end
end
return nil
end

function champ.abilities.r:use(context, cast)
cast.target:effect(invulnerable.new(2.5):on_finish(function()
self.proj = aoe:new(self, { colliders = context.enemies,
color = { 0.9,0.9,0.1 },
follow = cast.target,
size = 300,
deploy_time = 0.1,
})
context.spawn( self.proj
)
end))
end

function champ.abilities.r:hit(target)
damage:new(370.0, damage.MAGIC):deal(champ, target)
end

function champ.behaviour(ready, context)
champ.range = 525
champ:change_movement(movement.KITE)
end

  return champ
end

return kayle