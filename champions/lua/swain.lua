local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local root = require("effects.root")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local swain = {}

-- Constructor
function swain.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2450,
    armor = 105.4,
    mr = 62.6,
    ms = 330,
    sprite = 'swain.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.3, 525, 70, { 0.5,0.1,0.1 }),
    q = ranged_cast.new(4.5, 725),
    e = ranged_cast.new(10, 900),
    e_ret = ability:new(10),
    r = splash_cast.new(120, 250, 500),
  }

function champ.abilities.aa:hit(target)
damage:new(70, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.q:use(context, cast)
for i = 1 , 5 do
local dir = cast.dir :rotate (( i - ( 5 + 1 ) / 2 ) * 0.5 / ( 5 - 1 ))
self.proj = missile.new(self, { dir = dir,
colliders = context.enemies,
size = 150,
speed = 2500,
color = { 0.5,0.1,0.1 },
range = 725,
from = champ.pos,
})
context.spawn( self.proj
)
end
end

function champ.abilities.q:hit(target)
damage:new(100, damage.MAGIC):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 1600,
color = { 0.5,0.1,0.1 },
range = 900,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
if champ.abilities.e_ret.timer <= 0 then
champ.abilities.e_ret.timer = champ.abilities.e_ret.cd
self.proj.after = function() champ.abilities.e_ret:after_e(context, cast) end
end
end

function champ.abilities.e:hit(target)
damage:new(80, damage.MAGIC):deal(champ, target)
target:effect(root.new(1.5))
end

function champ.abilities.e_ret:after_e(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 1600,
color = { 0.5,0.1,0.1 },
range = nil,
stop_on_hit = true,
from = champ.abilities.e.proj,
to = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.e_ret:hit(target)
damage:new(80, damage.MAGIC):deal(champ, target)
target:effect(root.new(1.5))
end

function champ.abilities.r:use(context, cast)
self.active = true
self.proj = aoe:new(self, { colliders = context.enemies,
size = 500,
color = { 0.5,0.1,0.1 },
persist_time = 12,
tick = 0.5,
follow = champ,
}):on_impact(function()
champ.health = champ.health + 50 * distances.in_range(champ, context.enemies, 250)
end)
context.delay(12, function() self.active = false
end)
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(20, damage.MAGIC):deal(champ, target)
end

function champ.behaviour(ready, context)
if champ.abilities.r.active then
champ.range = 250-50
champ.target = context.closest_enemy
else
champ.range = 725+100
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return swain