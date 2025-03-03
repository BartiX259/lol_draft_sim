local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local pull = require("effects.pull")
local shield = require("effects.shield")
local suppress = require("effects.suppress")
local aoe = require("projectiles.aoe")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local skarner = {}

-- Constructor
function skarner.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2580,
    armor = 150.6,
    mr = 96.6,
    ms = 380,
    sprite = 'skarner.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.0, 175, 169),
    q = melee_aa_cast.new(5.4, 175, 222),
    e = ranged_cast.new(13.5, 700),
    r = ranged_cast.new(82, 190),
  }


function champ.abilities.q:hit(target)
damage:new(222, damage.PHYSICAL):deal(champ, target)
damage:new(222, damage.MAGIC):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
champ:effect(shield.new(2.5, 204.0))
champ:effect(pull.new(1650, cast.pos))
self.start_pos = champ.pos
local persist_time = cast.mag / 1650
self.proj = aoe:new(self, { colliders = context.enemies,
size = 700,
color = { 0.6,0.4,0.8 },
persist_time = persist_time,
tick = 0.1,
follow = champ,
re_hit = false,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(150, damage.MAGIC):deal(champ, target)
local time_left = ( champ.pos - self.start_pos ):mag () / 1650
target:effect(suppress.new(time_left, self.proj))
end

function champ.abilities.r:use(context, cast)
self.active = true
context.delay(1.5, function() self.active = false
end)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 380,
color = { 0.6,0.4,0.8 },
deploy_time = 0.65,
follow = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(250, damage.MAGIC):deal(champ, target)
target:effect(suppress.new(1.5, champ))
end

function champ.behaviour(ready, context)
if champ.abilities.r.active then
champ.range = 175+150
champ:change_movement(movement.PEEL)
elseif context.closest_dist < 175 + 50 then
champ.range = 175
champ.target = context.closest_enemy
else
champ.range = 175+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return skarner