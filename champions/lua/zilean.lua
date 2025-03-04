local always_cast = require("abilities.always")
local buff_cast = require("abilities.buff")
local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local speed = require("effects.speed")
local stun = require("effects.stun")
local aoe = require("projectiles.aoe")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local distances = require("util.distances")
local movement = require("util.movement")

local zilean = {}

-- Constructor
function zilean.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2176,
    armor = 84,
    mr = 45.6,
    ms = 380,
    sprite = 'zilean.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.52, 550, 88, { 0.9,0.8,0.5 }),
    q = splash_cast.new(5.7, 900, 350),
    e = buff_cast.new(12.5, 550),
    r = ability:new(50),
    r_res = always_cast.new(),
  }
champ.abilities.r_res:join(champ.abilities.r)

function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 350,
color = { 0.9,0.8,0.5 },
deploy_time = 0.3,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(390, damage.MAGIC):deal(champ, target)
target:effect(stun.new(1.5))
end

function champ.abilities.e:use(context, cast)
cast.target:effect(speed.new(2.5, 0.99))
end

function champ.abilities.r:cast(context)
for _,ally in pairs ( distances.in_range_list ( champ , context.allies , 900 )) do
if ally.health < 500 then
return { target = ally }
end
end
return nil
end

function champ.abilities.r:use(context, cast)
self.active = true
context.delay(6, function() self.active = false
end)
self.target = cast.target
end

function champ.abilities.r_res:precast(context, cast)
if champ.abilities.r.target.health <= 0 then return true end
end

function champ.abilities.r_res:use(context, cast)
if champ.abilities.r.target.health <= 0 then
champ.abilities.r.target.health = 1050
champ.abilities.r.active = false
end
end

function champ.behaviour(ready, context)
champ.range = 900
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return zilean