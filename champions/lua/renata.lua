local always_cast = require("abilities.always")
local big_cast = require("abilities.big")
local buff_cast = require("abilities.buff")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local damage_buff = require("effects.damage_buff")
local pull = require("effects.pull")
local root = require("effects.root")
local shield = require("effects.shield")
local slow = require("effects.slow")
local speed = require("effects.speed")
local stun = require("effects.stun")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local renata = {}

-- Constructor
function renata.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1963,
    armor = 71.4,
    mr = 65.6,
    ms = 385,
    sprite = 'renata.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.1, 550, 85, { 0.7,0.3,0.9 }),
    q = ranged_cast.new(6.3, 900),
    q_recast = ability:new(6.3),
    w = buff_cast.new(10.1, 800),
    w_res = always_cast.new(),
    e = ranged_cast.new(6.2, 800),
    r = big_cast.new(104, 2000, 250),
  }
champ.abilities.w_res:join(champ.abilities.w)

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 140,
speed = 1450,
color = { 0.7,0.3,0.9 },
range = 900,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
if champ.abilities.q_recast.timer <= 0 then
champ.abilities.q_recast.timer = champ.abilities.q_recast.cd
self.proj.after = function() champ.abilities.q_recast:after_q(context, cast) end
end
end

function champ.abilities.q:hit(target)
damage:new(292, damage.MAGIC):deal(champ, target)
target:effect(root.new(1.0))
end

function champ.abilities.q_recast:after_q(context, cast)
local pull_dir = ( cast.pos - champ.abilities.q.proj.pos ):normalize ()
local pull_dest = cast.target.pos + pull_dir * 350
cast.target:effect(pull.new(1200, pull_dest))
end

function champ.abilities.w:use(context, cast)
self.active = true
context.delay(5, function() self.active = false
end)
self.target = cast.target
cast.target:effect(speed.new(5.0, 0.2))
cast.target:effect(damage_buff.new(5.0, 0.3))
end

function champ.abilities.w_res:precast(context, cast)
if champ.abilities.w.target.health <= 0 then return true end
end

function champ.abilities.w_res:use(context, cast)
if champ.abilities.w.target.health <= 0 then
champ.abilities.w.target.health = 400
champ.abilities.w.active = false
end
end

function champ.abilities.e:use(context, cast)
local hit_cols = {}
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 220,
speed = 1450,
color = { 0.7,0.3,0.9 },
range = 800,
hit_cols = hit_cols,
from = champ.pos,
})
context.spawn( self.proj
)
for _,ally in pairs ( distances.in_range_list ( champ , context.allies , 330 )) do
ally:effect(shield.new(2.0, 230.0))
end
end

function champ.abilities.e:hit(target)
damage:new(207, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.0, 0.3))
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 250,
speed = 825,
color = { 0.7,0.3,0.9 },
range = 2000,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(300, damage.MAGIC):deal(champ, target)
target:effect(stun.new(2.0))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 900
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 900+150
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return renata