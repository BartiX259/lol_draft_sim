local dash_cast = require("abilities.dash")
local none_cast = require("abilities.none")
local ranged_cast = require("abilities.ranged")
local dash = require("effects.dash")
local pull = require("effects.pull")
local slow = require("effects.slow")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local tristana = {}

-- Constructor
function tristana.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1964,
    armor = 78,
    mr = 48.6,
    ms = 380,
    sprite = 'tristana.jpg',
    damage_split = { 0.7550759758640709, 0.24492402413592892, 0.0 }
  })
  champ.abilities = {
    aa = ranged_cast.new(0.871, 656),
    aa_explosion = none_cast.new(),
    w = dash_cast.new(10, 700, 656),
    r = ranged_cast.new(110, 656),
  }
function champ.abilities.aa:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 55,
speed = 2250,
color = { 0.8,0.6,0.2 },
range = nil,
from = champ.pos,
to = cast.target,
})
self.hit_cols = { [ cast.target ] = true }
context.spawn( self.proj
)
self.proj.after = function() champ.abilities.aa_explosion:after_aa(context, cast) end
end

function champ.abilities.aa:hit(target)
damage:new(230, damage.PHYSICAL):deal(champ, target)
end

function champ.abilities.aa_explosion:after_aa(context, cast)
local hit_cols = champ.abilities.aa.hit_cols
self.proj = aoe:new(self, { colliders = context.enemies,
size = 250,
color = { 0.8,0.6,0.2 },
hit_cols = hit_cols,
at = champ.abilities.aa.proj.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.aa_explosion:hit(target)
damage:new(215, damage.MAGIC):deal(champ, target)
end

function champ.abilities.w:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 350,
color = { 0.8,0.6,0.2 },
at = cast.pos,
})
champ:effect(dash.new(1500, cast.pos))
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
damage:new(320, damage.MAGIC):deal(champ, target)
target:effect(slow.new(2.0, 0.4))
end

function champ.abilities.r:precast(context, cast)
if context.closest_dist < 300 then
return cast
end
end

function champ.abilities.r:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 200,
speed = 2000,
color = { 0.8,0.6,0.2 },
range = 656,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(402, damage.MAGIC):deal(champ, target)
local knockback_dir = ( target.pos - champ.pos ):normalize ()
local knockback_dist = 600
local target_pos = target.pos + knockback_dir * knockback_dist
target:effect(pull.new(1800, target_pos))
end

function champ.behaviour(ready, context)
champ.range = 656
champ:change_movement(movement.KITE)
end

  return champ
end

return tristana