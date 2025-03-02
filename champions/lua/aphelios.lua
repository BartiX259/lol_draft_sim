local big_cast = require("abilities.big")
local ranged_cast = require("abilities.ranged")
local splash_cast = require("abilities.splash")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local aphelios = {}

-- Constructor
function aphelios.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1824,
    armor = 66.4,
    mr = 45.6,
    ms = 380,
    sprite = 'aphelios.jpg',
  })

  champ.abilities = {
    aa = ranged_cast.new(0.84, 550),
    aa_wave = ability:new(0.84),
    q = splash_cast.new(5.45, 650, 120),
    r = big_cast.new(100, 1300, 300),
    r_explosion = ability:new(100),
  }
function champ.abilities.aa:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 80,
speed = 1000,
color = { 0.3,0.4,0.7 },
range = nil,
from = champ.pos,
to = cast.target,
})
context.spawn( self.proj
)
if champ.abilities.aa_wave.timer <= 0 then
champ.abilities.aa_wave.timer = champ.abilities.aa_wave.cd
self.proj.after = function() champ.abilities.aa_wave:after_aa(context, cast) end
end
end

function champ.abilities.aa:hit(target)
damage:new(205, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.aa_wave:after_aa(context, cast)
local hit_cols = { [ cast.target ] = true }
for _,dir in pairs ( cast.dir :cone ( 40 , 4 )) do
context.spawn( missile.new(self, { dir = dir,
colliders = context.enemies,
size = 80,
speed = 1000,
color = { 0.3,0.4,0.7 },
range = 300,
hit_cols = hit_cols,
from = champ.abilities.aa.proj,
})
)
end
end

function champ.abilities.aa_wave:hit(target)
damage:new(205, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.q:use(context, cast)
local hit_cols = {}
for _,dir in pairs ( cast.dir :cone ( 40 , 4 )) do
self.proj = missile.new(self, { dir = dir,
colliders = context.enemies,
size = 120,
speed = 1850,
color = { 0.3,0.4,0.7 },
range = 650,
hit_cols = hit_cols,
from = champ.pos,
})
context.spawn( self.proj
)
end
end

function champ.abilities.q:hit(target)
damage:new(229, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 300,
speed = 1000,
color = { 0.3,0.4,0.7 },
range = 1300,
from = champ.pos,
})
context.spawn( self.proj
)
if champ.abilities.r_explosion.timer <= 0 then
champ.abilities.r_explosion.timer = champ.abilities.r_explosion.cd
self.proj.after = function() champ.abilities.r_explosion:after_r(context, cast) end
end
end

function champ.abilities.r:hit(target)
damage:new(216, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.r_explosion:after_r(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 400,
color = { 0.3,0.4,0.7 },
at = champ.abilities.r.proj,
})
context.spawn( self.proj
)
end

function champ.abilities.r_explosion:hit(target)
damage:new(151, damage.PHYSICAL):deal(champ, target)
end

function champ.behaviour(ready, context)
champ.range = 550
champ:change_movement(movement.KITE)
end

  return champ
end

return aphelios