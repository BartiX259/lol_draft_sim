local buff_cast = require("abilities.buff")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local charm = require("effects.charm")
local dash = require("effects.dash")
local pull = require("effects.pull")
local shield = require("effects.shield")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local thresh = {}

-- Constructor
function thresh.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2740,
    armor = 113,
    mr = 78.6,
    ms = 355,
    sprite = 'thresh.jpg',
    damage_split = { 0.0, 1.0, 0.0 }
  })
  champ.abilities = {
    aa = ranged_aa_cast.new(1.2, 450, 146, { 0.4,1.0,0.6 }),
    q = ranged_cast.new(7.2, 1100),
    w = buff_cast.new(13.1, 950),
    e = ranged_cast.new(7.8, 300),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 140,
speed = 1900,
color = { 0.4,1.0,0.6 },
range = 1100,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(345, damage.MAGIC):deal(champ, target)
target:effect(charm.new(1.5, 200, champ))
end

function champ.abilities.w:precast(context, cast)
if cast.target :has_effect ( "root" ) or cast.pos :distance ( context.enemies_avg_pos ) < 500 and cast.target.health < 1600 then
return cast
end
return nil
end

function champ.abilities.w:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 250,
speed = 1750,
color = { 0.4,1.0,0.6 },
range = 950,
from = champ.pos,
to = cast.pos,
})
self.proj.after = function ()
cast.target:effect(dash.new(1900, champ))
cast.target:effect(shield.new(2.0, 250.0))
end
context.spawn( self.proj
)
end

function champ.abilities.e:use(context, cast)
local start_pos = champ.pos - cast.dir * 300
self.end_pos = champ.pos + cast.dir * 300
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 220,
speed = 1000,
color = { 0.4,1.0,0.6 },
range = 300,
from = start_pos,
to = self.end_pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(290, damage.MAGIC):deal(champ, target)
target:effect(pull.new(1000, self.end_pos))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 1100-50
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 1100+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return thresh