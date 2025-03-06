local dash_cast = require("abilities.dash")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local airborne = require("effects.airborne")
local damage_buff = require("effects.damage_buff")
local dash = require("effects.dash")
local pull = require("effects.pull")
local resist_buff = require("effects.resist_buff")
local shield = require("effects.shield")
local speed = require("effects.speed")
local stun = require("effects.stun")
local unstoppable = require("effects.unstoppable")
local aoe = require("projectiles.aoe")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local ksante = {}

-- Constructor
function ksante.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2815,
    armor = 136.4,
    mr = 77.2,
    ms = 390,
    sprite = 'ksante.jpg',
    damage_split = { 0.9999999999999999, 0.0, 0.0 }
  })
  champ.abilities = {
    aa = melee_aa_cast.new(1.1, 150, 196),
    q = splash_cast.new(2.92, 230, 180),
    w = ranged_cast.new(9, 400),
    e = dash_cast.new(6.5, 250, 150),
    r = ranged_cast.new(83.33, 300),
  }

function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 180,
color = { 0.1,0.8,0.7 },
deploy_time = 0.4,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(231.2, damage.PHYSICAL):deal(champ, target)
target:effect(airborne.new(0.4))
end

function champ.abilities.w:use(context, cast)
champ:effect(resist_buff.new(1.0, 80.0))
champ:effect(stun.new(1.0))
champ:effect(unstoppable.new(1.0))
context.delay(1, function()
champ :del_effect ( "unstoppable" )
self.proj = aoe:new(self, { colliders = context.enemies,
color = { 0.1,0.8,0.7 },
follow = champ,
persist_time = 1,
size = 100,
tick = 0,
})
context.spawn( self.proj
)
local cpos = champ.pos + cast.dir * 400
champ:effect(dash.new(1800, cpos))
end)
end

function champ.abilities.w:hit(target)
damage:new(200, damage.PHYSICAL):deal(champ, target)
champ :del_effect ( "dash" )
self.proj.despawn = true
target:effect(stun.new(1.75))
end

function champ.abilities.e:use(context, cast)
champ:effect(dash.new(1400, cast.pos))
champ:effect(shield.new(2.5, 397.5))
end

function champ.abilities.r:use(context, cast)
local ppos = champ.pos + cast.dir * 700
cast.target:effect(pull.new(2000, ppos))
champ:effect(pull.new(2000, ppos))
champ:effect(damage_buff.new(15.0, 0.3))
local res_nerf = - 20
champ:effect(resist_buff.new(15.0, res_nerf))
champ:effect(speed.new(15.0, 0.15))
end

function champ.behaviour(ready, context)
if context.closest_dist < 150 + 100 then
champ.range = 150
champ.target = context.closest_enemy
elseif ready.w then
champ.range = 400
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 650
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return ksante