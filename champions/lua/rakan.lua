local buff_cast = require("abilities.buff")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local airborne = require("effects.airborne")
local charm = require("effects.charm")
local dash = require("effects.dash")
local shield = require("effects.shield")
local speed = require("effects.speed")
local aoe = require("projectiles.aoe")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local rakan = {}

-- Constructor
function rakan.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2478,
    armor = 104,
    mr = 76.6,
    ms = 390,
    sprite = 'rakan.jpg',
    damage_split = { 0.0, 1.0, 0.0 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(1.0, 300, 104),
    w = splash_cast.new(7, 600, 300),
    e = buff_cast.new(8.5, 700),
    r = ranged_cast.new(75, 150),
  }

function champ.abilities.w:use(context, cast)
local deploy_time = 0.15 + cast.mag / 1700
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.9,0.7,0.4 },
deploy_time = deploy_time,
at = cast.pos,
})
context.spawn( self.proj
)
champ:effect(dash.new(1700, cast.pos))
end

function champ.abilities.w:hit(target)
damage:new(286, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.0))
end

function champ.abilities.e:use(context, cast)
champ:effect(dash.new(2000, cast.target))
cast.target:effect(shield.new(2.0, 273.0))
end

function champ.abilities.r:use(context, cast)
self.active = true
context.delay(4, function() self.active = false
end)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.9,0.7,0.4 },
persist_time = 4,
tick = 0,
follow = champ,
re_hit = false,
})
champ:effect(speed.new(4, 0.75))
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(310, damage.MAGIC):deal(champ, target)
target:effect(charm.new(1.5, 200, champ))
end

function champ.behaviour(ready, context)
if champ.abilities.r.active then
champ.range = 150
champ:change_movement(movement.ENGAGE)
elseif ready.w then
champ.range = 600
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 600+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return rakan