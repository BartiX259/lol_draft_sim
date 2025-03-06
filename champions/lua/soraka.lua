local buff_cast = require("abilities.buff")
local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local silence = require("effects.silence")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local soraka = {}

-- Constructor
function soraka.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1961,
    armor = 59,
    mr = 45.6,
    ms = 385,
    sprite = 'soraka.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.2, 550, 86, { 0.8,1.0,0.8 }),
    q = splash_cast.new(4.7, 800, 265),
    w = buff_cast.new(3.5, 550),
    e = splash_cast.new(11.24, 925, 260),
    r = ability:new(128.51),
  }

function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 265,
color = { 0.8,1.0,0.8 },
deploy_time = 0.3,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
champ :heal ( 12.5 )
damage:new(260, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.0, 0.2))
end

function champ.abilities.w:precast(context, cast)
if cast.target.max_health - cast.target.health < 240 or champ.health < 196 then
return nil
end
return cast
end

function champ.abilities.w:use(context, cast)
cast.target :heal ( 240 )
champ :heal (- 196 )
end

function champ.abilities.e:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 260,
color = { 0.8,1.0,0.8 },
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(150, damage.MAGIC):deal(champ, target)
target:effect(silence.new(1.5))
end

function champ.abilities.r:cast(context)
local total = 0
local potential = 0
for _,ally in pairs ( context.allies ) do
if ally.health < 400 then
return true
end
total = total + math.min ( ally.max_health - ally.health , 330 )
potential = potential + 330
end
if total > 0.8 * potential then
return true
end
return false
end

function champ.abilities.r:use(context, cast)
for _,ally in pairs ( context.allies ) do
ally :heal ( 330 )
end
end

function champ.behaviour(ready, context)
champ.range = 800+100
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return soraka