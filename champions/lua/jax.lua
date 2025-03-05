local melee_aa_cast = require("abilities.melee_aa")
local none_cast = require("abilities.none")
local ranged_cast = require("abilities.ranged")
local dash = require("effects.dash")
local resist_buff = require("effects.resist_buff")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local jax = {}

-- Constructor
function jax.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2465,
    armor = 123,
    mr = 81,
    ms = 395,
    sprite = 'jax.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(0.66, 125, 209),
    q = ranged_cast.new(6.0, 700),
    w = ranged_cast.new(3.0, 175),
    w_hit = ranged_cast.new(0, 175),
    e = ranged_cast.new(8, 187),
    e_recast = none_cast.new(),
  }
champ.abilities.w_hit:join(champ.abilities.w)

function champ.abilities.q:use(context, cast)
champ:effect(dash.new(1400, cast.target))
end

function champ.abilities.q:hit(target)
damage:new(295, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
self.active = true
context.delay(5, function()
self.active = false
end)
end

function champ.abilities.w_hit:use(context, cast)
damage:new(220, damage.MAGIC):deal(champ, cast.target)
end

function champ.abilities.e:use(context, cast)
self.proj = aoe:new(self, { colliders = nil,
size = 375,
color = { 0.7,0.4,0.9 },
deploy_time = 0.1,
persist_time = 2,
follow = champ,
})
champ:effect(resist_buff.new(2, 60.0))
context.spawn( self.proj
)
self.proj.after = function() champ.abilities.e_recast:after_e(context, cast) end
end

function champ.abilities.e_recast:after_e(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 375,
color = { 0.7,0.4,0.9 },
at = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e_recast:hit(target)
damage:new(570, damage.MAGIC):deal(champ, target)
target:effect(stun.new(1.0))
end

function champ.behaviour(ready, context)
if context.closest_dist < 125 + 50 then
champ.range = 125
champ.target = context.closest_enemy
else
champ.range = 700+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return jax