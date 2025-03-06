local dash_cast = require("abilities.dash")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local dash = require("effects.dash")
local pull = require("effects.pull")
local stun = require("effects.stun")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local vayne = {}

-- Constructor
function vayne.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1936,
    armor = 78.2,
    mr = 45.6,
    ms = 375,
    sprite = 'vayne.jpg',
    damage_split = { 0.4821178120617111, 0.035764375876577846, 0.4821178120617111 }
  })
  champ.abilities = {
    aa = ranged_aa_cast.new(0.68, 550, 220, { 0.3,0.3,0.3 }),
    q = dash_cast.new(2, 300, 550),
    e = ranged_cast.new(10, 450),
  }
function champ.abilities.aa:start()
self.counter = 2
end


function champ.abilities.aa:hit(target)
self.counter = ( self.counter + 1 ) % 3
if self.counter == 2 then
damage:new(220, damage.TRUE):deal(champ, target)
else
damage:new(220, damage.PHYSICAL):deal(champ, target)
end
end

function champ.abilities.q:use(context, cast)
champ:effect(dash.new(875, cast.pos))
end

function champ.abilities.e:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 100,
speed = 2200,
color = { 0.3,0.3,0.3 },
range = 450,
from = champ.pos,
to = cast.target,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(240, damage.MAGIC):deal(champ, target)
local ppos = ( target.pos - champ.pos ):normalize () * 400
target:effect(stun.new(1.5))
target:effect(pull.new(2200, ppos))
end

function champ.behaviour(ready, context)
champ.range = 550+50
champ:change_movement(movement.KITE)
end

  return champ
end

return vayne