local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")
local aoe = require("projectiles.aoe")
local melee_aa = require("abilities.melee_aa")
local splash = require("abilities.splash")
local none = require("abilities.none")
local airborne = require("effects.airborne")
local pull = require("effects.pull")

local wukong = {}

-- Constructor
function wukong.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1694,
    armor = 162.5,
    mr = 50.45,
    ms = 385,
    sprite = 'wukong.jpg',
  })

  champ.abilities = {
    aa = melee_aa.new(1.2, 175, 195),
    e = splash.new(5.5, 925, 370),
    r = splash.new(70, 200, 370),
    r_ticks = none.new(),
    r_end = none.new(),
  }

function champ.abilities.e:use(context, cast)
champ:effect(pull.new(1550.0, cast.target))
self.proj = aoe:new(self, { colliders = context.enemies,
size = 370,
color = { 0.9,0.9,0.9,0.9 },
deploy_time = 0.6,
persist_time = 0.1,
follow = champ,
hard_follow = true,
at = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(200, damage.MAGIC):deal(champ, target)
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 370,
color = { 0.9,0.9,0.9,0.9 },
deploy_time = 0.5,
persist_time = 0.15,
follow = champ,
hard_follow = true,
at = champ,
})
champ.spinning = true
context.spawn( self.proj
)
champ.abilities.r_ticks:with_r(context, cast)
end

function champ.abilities.r:hit(target)
damage:new(91.2, damage.PHYSICAL):deal(champ, target)
target:effect(airborne.new(1.0))
end

function champ.abilities.r_ticks:with_r(context, cast)
local proj_one = aoe:new(self, { colliders = context.enemies,
size = 370,
color = { 0.9,0.9,0.9,0.9 },
deploy_time = 0,
persist_time = 0.15,
follow = champ,
hard_follow = true,
})
champ.abilities.r.proj.next = proj_one
local proj_temp = proj_one
for i = 1 , 7 do
proj_temp.next = aoe:new(self, { colliders = context.enemies,
size = 370,
color = { 0.9,0.9,0.9,0.9 },
deploy_time = 0,
persist_time = 0.15,
follow = champ,
hard_follow = true,
})
proj_temp = proj_temp.next
end
self.proj = proj_temp
self.proj.after = function() champ.abilities.r_end:after_r_ticks(context, cast) end
end

function champ.abilities.r_ticks:hit(target)
damage:new(91.2, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.r_end:after_r_ticks(context, cast)
champ.spinning = false
end

function champ.behaviour(ready, context)
if champ.spinning or context.closest_dist < 175 + 100 then
champ.range = 175
champ.target = context.closest_enemy
elseif ready.e then
champ.range = 175
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 925+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return wukong