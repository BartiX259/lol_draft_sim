local melee_aa_cast = require("abilities.melee_aa")
local none_cast = require("abilities.none")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local jarvan_iv = {}

-- Constructor
function jarvan_iv.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2488,
    armor = 108.4,
    mr = 68.6,
    ms = 380,
    sprite = 'jarvan_iv.jpg',
    damage_split = { 0.8954388240412655, 0.10456117595873438, 0.0 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(1.3, 175, 223),
    q = ranged_cast.new(4.5, 800),
    e = ability:new(8.3),
    knockup = none_cast.new(),
    r = splash_cast.new(75, 400, 400),
  }

function champ.abilities.aa:hit(target)
damage:new(223, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 150,
speed = 1600,
color = { 0.9,0.7,0.2 },
range = 800,
from = champ.pos,
})
context.spawn( self.proj
)
if champ.abilities.e.timer <= 0 then
champ.abilities.e.timer = champ.abilities.e.cd
champ.abilities.e:with_q(context, cast)
end
end

function champ.abilities.q:hit(target)
damage:new(310, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.e:with_q(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 120,
color = { 0.2,0.6,0.9 },
at = cast.pos,
})
context.spawn( self.proj
)
champ.abilities.q.proj.after = function ()
self.active = true
champ:effect(dash.new(1800, cast.pos):on_finish(function()
context.despawn( champ.abilities.knockup.proj
)
self.active = false
end))
end
champ.abilities.knockup:with_e(context, cast)
end

function champ.abilities.e:hit(target)
damage:new(240, damage.MAGIC):deal(champ, target)
end

function champ.abilities.knockup:with_e(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 100,
color = { 0.9,0.7,0.2 },
deploy_time = 0,
persist_time = 10,
tick = 0,
follow = champ,
re_hit = false,
})
context.spawn( self.proj
)
end

function champ.abilities.knockup:hit(target)
target:effect(airborne.new(1.0))
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 400,
color = { 0.9,0.7,0.2 },
deploy_time = 0.2,
at = cast.pos,
})
champ:effect(dash.new(1800, cast.pos))
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(540, damage.PHYSICAL):deal(champ, target)
target:effect(stun.new(1.25))
end

function champ.behaviour(ready, context)
if ready.e then
champ.range = 700
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 800+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return jarvan_iv