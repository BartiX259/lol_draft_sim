local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local airborne = require("effects.airborne")
local dash = require("effects.dash")
local pull = require("effects.pull")
local aoe = require("projectiles.aoe")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local alistar = {}

-- Constructor
function alistar.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2935,
    armor = 158.4,
    mr = 126.6,
    ms = 385,
    sprite = 'alistar.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.1, 125, 127),
    q = splash_cast.new(4.7, 187, 375),
    w = ranged_cast.new(6.3, 650),
  }

function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 375,
color = { 0.6,0.3,0.1 },
at = champ,
deploy_time = 0.1,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(250, damage.MAGIC):deal(champ, target)
target:effect(airborne.new(1.5))
end

function champ.abilities.w:use(context, cast)
champ:effect(dash.new(1500, cast.target):on_finish(function()
damage:new(275, damage.MAGIC):deal(champ, cast.target)
local pull_pos = cast.target.pos + cast.dir * 400
cast.target:effect(pull.new(1500, pull_pos))
end))
end

function champ.behaviour(ready, context)
champ.range = 650+100
champ:change_movement(movement.PEEL)
end

  return champ
end

return alistar