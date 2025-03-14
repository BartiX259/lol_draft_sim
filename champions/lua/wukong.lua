local melee_aa_cast = require("abilities.melee_aa")
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
    health = 2533,
    armor = 180.4,
    mr = 72.65,
    ms = 385,
    sprite = 'wukong.jpg',
    damage_split = { 0.1073038773669973, 0.8926961226330028, 0.0 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(1.2, 175, 223),
    e = splash_cast.new(5.6, 625, 250),
    r = splash_cast.new(72, 200, 265),
    r_ticks = ability:new(72),
    r_end = ability:new(10),
  }

function champ.abilities.e:use(context, cast)
champ:effect(dash.new(1550, cast.target))
self.proj = aoe:new(self, { colliders = context.enemies,
size = 250,
color = { 0.9,0.9,0.9,0.9 },
deploy_time = 0.1,
persist_time = 0.1,
follow = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(220, damage.MAGIC):deal(champ, target)
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 265,
color = { 0.9,0.9,0.9,0.9 },
deploy_time = 0,
persist_time = 2,
follow = champ,
})
champ.spinning = true
context.spawn( self.proj
)
if champ.abilities.r_ticks.timer <= 0 then
champ.abilities.r_ticks.timer = champ.abilities.r_ticks.cd
champ.abilities.r_ticks:with_r(context, cast)
end
end

function champ.abilities.r:hit(target)
damage:new(170, damage.PHYSICAL):deal(champ, target)
target:effect(airborne.new(0.6))
end

function champ.abilities.r_ticks:with_r(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 265,
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
damage:new(170, damage.PHYSICAL):deal(champ, target)
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