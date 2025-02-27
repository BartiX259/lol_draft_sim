local melee_aa_cast = require("abilities.melee_aa")
local none_cast = require("abilities.none")
local splash_cast = require("abilities.splash")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local aoe = require("projectiles.aoe")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local wukong = {}

-- Constructor
function wukong.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2198,
    armor = 150.4,
    mr = 52.65,
    ms = 385,
    sprite = 'wukong.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.2, 175, 203),
    e = splash_cast.new(5.6, 625, 190),
    r = splash_cast.new(72, 200, 165),
    r_ticks = none_cast.new(),
    r_end = ability:new(10),
  }

function champ.abilities.e:use(context, cast)
champ:effect(dash.new(1550.0, cast.target))
self.proj = aoe:new(self, { colliders = context.enemies,
size = 190,
color = { 0.9,0.9,0.9,0.9 },
deploy_time = 0.1,
persist_time = 0.1,
follow = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(200, damage.MAGIC):deal(champ, target)
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 165,
color = { 0.9,0.9,0.9,0.9 },
deploy_time = 0,
persist_time = 2,
follow = champ,
})
champ.spinning = true
context.spawn( self.proj
)
champ.abilities.r_ticks:with_r(context, cast)
end

function champ.abilities.r:hit(target)
damage:new(120, damage.PHYSICAL):deal(champ, target)
target:effect(airborne.new(0.6))
end

function champ.abilities.r_ticks:with_r(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 165,
color = { 0.9,0.9,0.9,0.9 },
deploy_time = 0,
persist_time = 2,
tick = 0.25,
follow = champ,
})
champ.abilities.r.proj.next = self.proj
if champ.abilities.r_end.timer <= 0 then
champ.abilities.r_end.timer = champ.abilities.r_end.cd
self.proj.after = function() champ.abilities.r_end:after_r_ticks(context, cast) end
end
end

function champ.abilities.r_ticks:hit(target)
damage:new(120, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.r_end:after_r_ticks(context, cast)
champ.spinning = false
context.delay(1, function() champ.abilities.r.timer = 0
end)
context.delay(8, function()
if champ.abilities.r.timer <= 0 then
champ.abilities.r.timer = 72
end
end)
end

function champ.behaviour(ready, context)
if champ.spinning or context.closest_dist < 175 + 100 then
champ.range = 175
champ.target = context.closest_enemy
elseif ready.e then
champ.range = 175
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 625
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return wukong