local buff_cast = require("abilities.buff")
local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local root = require("effects.root")
local shield = require("effects.shield")
local slow = require("effects.slow")
local speed = require("effects.speed")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local ability = require("util.ability")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local karma = {}

-- Constructor
function karma.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2088,
    armor = 103,
    mr = 65.6,
    ms = 390,
    sprite = 'karma.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.6, 525, 91, { 0.2,0.9,0.6 }),
    q = ranged_cast.new(3.85, 950),
    q_splash = ability:new(3.85),
    w = ranged_cast.new(9.23, 675),
    e = buff_cast.new(6.15, 800),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 140,
speed = 1700,
color = { 0.2,0.9,0.6 },
range = 950,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
if champ.abilities.q_splash.timer <= 0 then
champ.abilities.q_splash.timer = champ.abilities.q_splash.cd
self.proj.after = function() champ.abilities.q_splash:after_q(context, cast) end
end
end

function champ.abilities.q:hit(target)
damage:new(240, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.5, 0.4))
end

function champ.abilities.q_splash:after_q(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 280,
color = { 0.2,0.9,0.6 },
at = champ.abilities.q.proj,
})
context.spawn( self.proj
)
end

function champ.abilities.q_splash:hit(target)
damage:new(240, damage.MAGIC):deal(champ, target)
target:effect(slow.new(1.5, 0.4))
end

function champ.abilities.w:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 50,
speed = 450,
color = { 0.2,0.9,0.6 },
range = 675,
from = champ.pos,
to = cast.target,
})
context.spawn( self.proj
)
end

function champ.abilities.w:hit(target)
target:effect(root.new(2))
damage:new(194, damage.MAGIC):deal(champ, target)
end

function champ.abilities.e:use(context, cast)
cast.target:effect(shield.new(2.5, 322.0))
cast.target:effect(speed.new(2.0, 0.4))
end

function champ.behaviour(ready, context)
if ready.q then
champ.range = 950
champ:change_movement(movement.AGGRESSIVE)
else
champ.range = 950+100
champ:change_movement(movement.PASSIVE)
end
end

  return champ
end

return karma