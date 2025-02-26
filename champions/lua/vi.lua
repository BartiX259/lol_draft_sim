local ranged = require("abilities.ranged")
local melee_aa = require("abilities.melee_aa")
local shield = require("effects.shield")
local pull = require("effects.pull")
local airborne = require("effects.airborne")
local aoe = require("projectiles.aoe")
local movement = require("util.movement")
local damage = require("util.damage")
local champion = require("util.champion")

local vi = {}

-- Constructor
function vi.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2543,
    armor = 86.4,
    mr = 56.6,
    ms = 424,
    sprite = 'vi.jpg',
  })

  champ.abilities = {
    aa = melee_aa.new(1, 150, 300),
    q = ranged.new(6, 725),
    r = ranged.new(115, 800),
  }

function champ.abilities.q:use(context, cast)
champ:effect(pull.new(1400.0, cast.pos):on_finish(function()
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
champ:effect(pull.new(1400.0, cast.target):on_finish(function()
context.spawn( aoe:new(self, { colliders = context.enemies,
size = 220,
color = { 0.9,0.2,0.2 },
at = champ.pos,
})
)
end))
end

function champ.abilities.r:hit(target)
damage:new(360, damage.PHYSICAL):deal(champ, target)
target:effect(airborne.new(1.25))
end

function champ.behaviour(ready, context)
if ready.r then
champ.range = 800
champ:change_movement(movement.AGGRESSIVE)
elseif ready.q then
champ.range = 725
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 150+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return vi