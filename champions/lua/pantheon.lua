local big_cast = require("abilities.big")
local dash_cast = require("abilities.dash")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local dash = require("effects.dash")
local fly = require("effects.fly")
local silence = require("effects.silence")
local slow = require("effects.slow")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local pantheon = {}

-- Constructor
function pantheon.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2348,
    armor = 114.4,
    mr = 72.6,
    ms = 375,
    sprite = 'pantheon.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.122, 175, 223.6),
    q = ranged_cast.new(5.2, 1200),
    w = ranged_cast.new(8, 600),
    e = dash_cast.new(14.1, 0, 525),
    r = big_cast.new(120, 1500, 450),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 2700,
color = { 0.8,0.6,0.1 },
range = 1200,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(583, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
champ:effect(dash.new(1500, cast.target):on_finish(function()
cast.target:effect(stun.new(1.0))
end))
end

function champ.abilities.w:hit(target)
damage:new(144, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
self.proj = aoe:new(self, { colliders = context.projectiles,
size = 300,
color = { 0.8,0.6,0.1 },
persist_time = 1.5,
tick = 0.125,
follow = champ,
})
context.spawn( self.proj
)
champ:effect(slow.new(1.5, 0.25))
champ:effect(silence.new(1.5))
end

function champ.abilities.e:hit(target)
target.hit_cols [ champ ] = true
end

function champ.abilities.r:use(context, cast)
local ch = 2 / 2
champ:effect(fly.new(2, ch):on_finish(function()
champ.pos = cast.pos
end))
self.proj = aoe:new(self, { colliders = context.enemies,
size = 450,
color = { 0.8,0.6,0.1 },
deploy_time = 2,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(400, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.0, 0.5))
end

function champ.behaviour(ready, context)
if context.closest_dist < 175 + 100 then
champ.range = 175
champ.target = context.closest_enemy
elseif ready.w then
champ.range = 600
champ:change_movement(movement.AGGRESSIVE)
elseif ready.q then
champ.range = 1200
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 1200+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return pantheon