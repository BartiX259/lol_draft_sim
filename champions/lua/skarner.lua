local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local pull = require("effects.pull")
local shield = require("effects.shield")
local slow = require("effects.slow")
local suppress = require("effects.suppress")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local skarner = {}

-- Constructor
function skarner.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2580,
    armor = 135.6,
    mr = 96.6,
    ms = 380,
    sprite = 'skarner.jpg',
    damage_split = { 0.7630498360462026, 0.23695016395379756, 0.0 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(1.0, 175, 169),
    q = ranged_cast.new(5.2, 475),
    e = ranged_cast.new(12.5, 700),
    r = ranged_cast.new(82, 190),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 250,
speed = 1600,
color = { 0.6,0.4,0.8 },
range = 475,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(252, damage.PHYSICAL):deal(champ, target)
target:effect(slow.new(2.0, 0.4))
end

function champ.abilities.e:use(context, cast)
champ:effect(shield.new(2.5, 204.0))
champ:effect(pull.new(850, cast.pos))
self.start_pos = champ.pos
local persist_time = cast.mag / 850
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
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
local time_left = ( champ.pos - self.start_pos ):mag () / 850
target:effect(suppress.new(time_left, self.proj))
end

function champ.abilities.r:use(context, cast)
self.casting = true
context.delay(0.65, function()
self.casting = false
self.active = true
end)
local del = 1.5 + 0.65
context.delay(del, function() self.active = false
end)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 350,
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
if champ.abilities.r.casting then
champ.range = 175
champ.target = context.closest_enemy
elseif champ.abilities.r.active then
champ.range = 475+150
champ:change_movement(movement.PEEL)
elseif context.closest_dist < 175 + 50 then
champ.range = 175
champ.target = context.closest_enemy
else
champ.range = 475+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return skarner