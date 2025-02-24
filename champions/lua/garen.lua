local champion = require("util.champion")
local damage = require("util.damage")
local ability = require("util.ability")
local movement = require("util.movement")
local aoe = require("projectiles.aoe")
local melee_aa = require("abilities.melee_aa")
local ranged = require("abilities.ranged")
local speed = require("effects.speed")
local silence = require("effects.silence")

local garen = {}

-- Constructor
function garen.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2616,
    armor = 88.4,
    mr = 50.6,
    ms = 424,
    sprite = 'garen.jpg',
  })

  champ.abilities = {
    aa = melee_aa.new(1.11, 175, 228),
    q = ranged.new(5.6, 400),
    q_hit = ranged.new(0, 200),
    e = ranged.new(6.3, 150),
    r = ability:new(56),
  }
champ.abilities.q_hit:join(champ.abilities.q)

function champ.abilities.q:use(context, cast)
self.active = true
champ:effect(speed.new(3.6, 0.35):on_finish(function() self.active = false
end))
end

function champ.abilities.q_hit:use(context, cast)
damage:new(264, damage.PHYSICAL):deal(champ, cast.target)
cast.target:effect(silence.new(1.5))
end

function champ.abilities.e:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.9,0.7,0.5 },
follow = champ,
hard_follow = true,
})
local num_ticks = 9
local current_proj = self.proj
for i = 1 , num_ticks - 1 do
current_proj.next = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.9,0.7,0.5 },
follow = champ,
hard_follow = true,
})
current_proj = current_proj.next
end
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(106.2, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.r:cast(context)
if champ.target and champ.target.pos :distance ( champ.pos ) < 400 and ( champ.target.health < 550 or champ.health / champ.max_health < 0.2 ) then
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
}):on_impact(function()
damage:new(550, damage.TRUE):deal(champ, cast.target)
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