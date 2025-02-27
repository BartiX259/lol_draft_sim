local dash = require("abilities.dash")
local ranged = require("abilities.ranged")
local ranged_aa = require("abilities.ranged_aa")
local splash = require("abilities.splash")
local charm = require("effects.charm")
local pull = require("effects.pull")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local ahri = {}

-- Constructor
function ahri.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1838,
    armor = 77.4,
    mr = 45.6,
    ms = 375,
    sprite = 'ahri.jpg',
  })

  champ.abilities = {
    aa = ranged_aa.new(1.185, 550, 89, { 0.4,0.5,0.9 }),
    q = splash.new(7, 900, 200),
    q_ret = ability:new(7),
    e = ranged.new(12, 1000),
    r = dash.new(115, 500, champ.range),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 200,
speed = 1750,
color = { 0.4,0.5,0.9 },
range = 900,
from = champ.pos,
})
context.spawn( self.proj
)
if champ.abilities.q_ret.timer <= 0 then
champ.abilities.q_ret.timer = champ.abilities.q_ret.cd
self.proj.after = function() champ.abilities.q_ret:after_q(context, cast) end
end
end

function champ.abilities.q:hit(target)
damage:new(266, damage.MAGIC):deal(champ, target)
end

function champ.abilities.q_ret:after_q(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 200,
speed = 1750,
color = { 0.4,0.5,0.9 },
range = nil,
from = champ.abilities.q.proj,
to = champ,
})
context.spawn( self.proj
)
end

function champ.abilities.q_ret:hit(target)
damage:new(266, damage.MAGIC):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 120,
speed = 1550,
color = { 1,0.2,0.8 },
range = 1000,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.e:hit(target)
damage:new(429, damage.MAGIC):deal(champ, target)
target:effect(charm.new(2.0, 244.0, champ))
end

function champ.abilities.r:use(context, cast)
champ:effect(pull.new(1300.0, cast.pos):on_finish(function()
if context.closest_dist < 900 then
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 100,
speed = 1400,
color = { 0.4,0.5,0.9 },
from = champ.pos,
to = cast.target,
range = nil,
})
context.spawn( self.proj
)
end
end))
end

function champ.abilities.r:hit(target)
damage:new(208, damage.MAGIC):deal(champ, target)
end

function champ.behaviour(ready, context)
if ready.e then
champ.range = 1000
champ:change_movement(movement.AGGRESSIVE)
elseif ready.q then
champ.range = 900
champ:change_movement(movement.PASSIVE)
else
champ.range = 900+150
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return ahri