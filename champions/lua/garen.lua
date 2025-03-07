local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local silence = require("effects.silence")
local speed = require("effects.speed")
local aoe = require("projectiles.aoe")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local garen = {}

-- Constructor
function garen.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2466,
    armor = 103.74,
    mr = 85.66,
    ms = 385,
    sprite = 'garen.jpg',
    damage_split = { 0.9045813467482574, 0.0, 0.09541865325174256 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(0.9, 175, 188),
    q = ranged_cast.new(6.45, 400),
    q_hit = ranged_cast.new(0, 200),
    e = ranged_cast.new(7.32, 325),
    r = ability:new(76.9),
  }
champ.abilities.q_hit:join(champ.abilities.q)

function champ.abilities.q:use(context, cast)
self.active = true
champ:effect(speed.new(3.6, 0.35):on_finish(function() self.active = false
end))
end

function champ.abilities.q_hit:use(context, cast)
damage:new(244, damage.PHYSICAL):deal(champ, cast.target)
cast.target:effect(silence.new(1.5))
end

function champ.abilities.e:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 325,
color = { 0.9,0.7,0.5 },
persist_time = 3,
tick = 0.375,
follow = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(85.2, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.r:cast(context)
if champ.target and champ.target.pos :distance ( champ.pos ) < 400 and ( champ.target.health < 500 or champ.health / champ.max_health < 0.2 ) then
return { target = champ.target }
end
return nil
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = nil,
size = 200,
color = { 1,1,1 },
deploy_time = 0.5,
follow = cast.target,
soft_follow = true,
}):on_impact(function()
damage:new(500, damage.TRUE):deal(champ, cast.target)
end)
context.spawn( self.proj
)
end

function champ.behaviour(ready, context)
if champ.abilities.q.active or context.closest_dist < 200 then
champ.target = context.closest_enemy
champ.range = 175*2-20
else
champ.range = 600
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return garen