local melee_aa = require("abilities.melee_aa")
local ranged = require("abilities.ranged")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local shield = require("effects.shield")
local unstoppable = require("effects.unstoppable")
local aoe = require("projectiles.aoe")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local vi = {}

-- Constructor
function vi.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1843,
    armor = 106.4,
    mr = 56.6,
    ms = 412,
    sprite = 'vi.jpg',
  })

  champ.abilities = {
    aa = melee_aa.new(1, 150, 195),
    q = ranged.new(6, 725),
    r = ranged.new(115, 800),
  }

function champ.abilities.q:precast(context, cast)
if cast.target :has_effect (" stun ") or champ.abilities.r.active then
return nil
end
return cast
end

function champ.abilities.q:use(context, cast)
champ:effect(dash.new(1400.0, cast.pos):on_finish(function()
champ:effect(shield.new(1.0, 305.0))
context.spawn( aoe:new(self, { colliders = context.enemies,
size = 120,
color = { 0.9,0.2,0.2 },
at = champ.pos,
})
)
end))
end

function champ.abilities.q:hit(target)
damage:new(450, damage.PHYSICAL):deal(champ, target)
target:effect(airborne.new(1.0))
end

function champ.abilities.r:use(context, cast)
champ:effect(unstoppable.new(1.5))
self.active = true
champ:effect(dash.new(1400.0, cast.target):on_finish(function()
champ :del_effect (" unstoppable ")
context.spawn( aoe:new(self, { colliders = context.enemies,
size = 150,
color = { 0.9,0.2,0.2 },
at = champ.pos,
})
)
end))
end

function champ.abilities.r:hit(target)
damage:new(360, damage.PHYSICAL):deal(champ, target)
self.active = false
target:effect(airborne.new(1.3))
end

function champ.behaviour(ready, context)
if context.closest_dist < 150 + 50 then
champ.range = 150
champ.target = context.closest_enemy
elseif ready.q then
champ.range = 725
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 725+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return vi