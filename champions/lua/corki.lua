local dash_cast = require("abilities.dash")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local dash = require("effects.dash")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local corki = {}

-- Constructor
function corki.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1810,
    armor = 84,
    mr = 45.6,
    ms = 350,
    sprite = 'corki.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(0.859, 550, 179, { 0.8,0.6,0.3 }),
    q = splash_cast.new(7.36, 825, 275),
    w = dash_cast.new(10.91, 600, 600),
    r = ranged_cast.new(2.5, 1500),
  }

function champ.abilities.aa:hit(target)
damage:new(179, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.q:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 275,
color = { 0.8,0.6,0.3 },
deploy_time = 0.227,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(406, damage.MAGIC):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
champ:effect(dash.new(650, cast.pos))
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 160,
speed = 2000,
color = { 0.8,0.6,0.3 },
range = 1500,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(286, damage.PHYSICAL):deal(champ, target)
end

function champ.behaviour(ready, context)
champ.range = 1500
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return corki