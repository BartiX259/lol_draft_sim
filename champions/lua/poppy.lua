local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local pull = require("effects.pull")
local silence = require("effects.silence")
local slow = require("effects.slow")
local speed = require("effects.speed")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local poppy = {}

-- Constructor
function poppy.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2508,
    armor = 112.3,
    mr = 88.2,
    ms = 395,
    sprite = 'poppy.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.1, 175, 134),
    q = ranged_cast.new(4.17, 200),
    q_second = ability:new(4.17),
    w = ability:new(11.47),
    e = ranged_cast.new(7.28, 525),
    r = splash_cast.new(83.48, 300, 300),
  }

function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 200,
color = { 0.9,0.6,0.3 },
deploy_time = 0.2,
at = cast.pos,
})
context.spawn( self.proj
)
if champ.abilities.q_second.timer <= 0 then
champ.abilities.q_second.timer = champ.abilities.q_second.cd
self.proj.after = function() champ.abilities.q_second:after_q(context, cast) end
end
end

function champ.abilities.q:hit(target)
damage:new(230, damage.PHYSICAL):deal(champ, target)
target:effect(slow.new(1.0, 0.4))
end

function champ.abilities.q_second:after_q(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 200,
color = { 0.9,0.6,0.3 },
deploy_time = 0.2,
at = champ.abilities.q.proj.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q_second:hit(target)
damage:new(230, damage.PHYSICAL):deal(champ, target)
target:effect(slow.new(1.0, 0.4))
end

function champ.abilities.w:cast(context)
for _,enemy in pairs ( distances.in_range_list(champ, context.enemies, 200) ) do
if enemy :has_effect ( "dash" ) then
return true
end
end
end

function champ.abilities.w:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 400,
color = { 0.9,0.6,0.3 },
persist_time = 2.5,
follow = champ,
tick = 0,
})
champ:effect(speed.new(2.5, 0.3))
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
if target :has_effect ( "dash" ) then
damage:new(230, damage.MAGIC):deal(champ, target)
target :del_effect ( "dash" )
target:effect(slow.new(1.2, 0.5))
target:effect(silence.new(1.2))
target:effect(airborne.new(0.5))
end
end

function champ.abilities.e:use(context, cast)
local target_pos = champ.pos + cast.dir * 525
champ:effect(dash.new(1600, target_pos))
cast.target:effect(stun.new(1.3))
cast.target:effect(pull.new(1400, target_pos))
damage:new(300, damage.PHYSICAL):deal(champ, cast.target)
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.9,0.6,0.3 },
deploy_time = 0.1,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(320, damage.PHYSICAL):deal(champ, target)
target:effect(airborne.new(1.0))
end

function champ.behaviour(ready, context)
if ready.e then
champ.range = 525
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 200+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return poppy