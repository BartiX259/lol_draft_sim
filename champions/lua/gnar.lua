local dash_cast = require("abilities.dash")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local dash = require("effects.dash")
local pull = require("effects.pull")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local gnar = {}

-- Constructor
function gnar.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2488,
    armor = 126,
    mr = 96,
    ms = 380,
    sprite = 'gnar.jpg',
    damage_split = { 1.0, 0.0, 0.0 }
  })
  champ.abilities = {
    aa = ranged_aa_cast.new(0.96, 500, 158, { 0.7,0.7,0.4 }),
    q = ranged_cast.new(9.5, 1100),
    q_ret = ability:new(9.5),
    e_engage = ranged_cast.new(11.4, 500),
    e_normal = dash_cast.new(11.4, 500, 500),
    r = splash_cast.new(57.1, 200, 300),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 100,
speed = 1400,
color = { 0.7,0.7,0.4 },
range = 1100,
from = champ.pos,
})
context.spawn( self.proj
)
if champ.abilities.q_ret.timer <= 0 then
champ.abilities.q_ret.timer = champ.abilities.q_ret.cd
self.proj.after = function() champ.abilities.q_ret:after_q(context, cast) end
end
end

function champ.abilities.q:hit(target)
damage:new(363, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.q_ret:after_q(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 100,
speed = 1400,
color = { 0.7,0.7,0.4 },
range = nil,
from = champ.abilities.q.proj,
to = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.q_ret:hit(target)
damage:new(363, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.e_engage:precast(context, cast)
if champ.abilities.r.timer <= 0 then
return cast
end
end

function champ.abilities.e_engage:use(context, cast)
local cpos = cast.pos - cast.dir * 100
champ:effect(dash.new(1400, cpos))
end

function champ.abilities.e_normal:precast(context, cast)
if champ.abilities.r.timer > 0 then
return cast
end
end

function champ.abilities.e_normal:use(context, cast)
champ:effect(dash.new(1400, cast.pos))
end

function champ.abilities.r:use(context, cast)
self.used = true
self.proj = aoe:new(self, { colliders = context.enemies,
size = 300,
color = { 0.7,0.7,0.4 },
at = champ,
})
self.dir = ( champ.pos - context.closest_enemy.pos ):normalize ()
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(330, damage.PHYSICAL):deal(champ, target)
local tpos = target.pos + self.dir * 300
target:effect(pull.new(1000, tpos))
target:effect(stun.new(1.5))
end

function champ.behaviour(ready, context)
champ.range = 500
champ:change_movement(movement.KITE)
end

  return champ
end

return gnar