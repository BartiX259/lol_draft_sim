local buff_cast = require("abilities.buff")
local melee_aa_cast = require("abilities.melee_aa")
local ranged_cast = require("abilities.ranged")
local dash = require("effects.dash")
local pull = require("effects.pull")
local shield = require("effects.shield")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local lee_sin = {}

-- Constructor
function lee_sin.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 2541,
    armor = 95,
    mr = 57,
    ms = 345,
    sprite = 'lee_sin.jpg',
  })

  champ.abilities = {
    aa = melee_aa_cast.new(1.2, 125, 203),
    q = ranged_cast.new(5.7, 1000),
    w = buff_cast.new(11.4, 400),
    r = ranged_cast.new(81, 300),
  }

function champ.abilities.q:use(context, cast)
self.proj = missile.new(self, { dir = cast.dir,
colliders = context.enemies,
size = 150,
speed = 1800,
color = { 0.4,0.6,0.8 },
range = 1000,
stop_on_hit = true,
from = champ.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(389, damage.PHYSICAL):deal(champ, target)
champ:effect(dash.new(1695, target))
end

function champ.abilities.w:use(context, cast)
champ:effect(dash.new(1695, cast.pos))
champ:effect(shield.new(1.0, 250.0))
cast.target:effect(shield.new(1.0, 250.0))
end

function champ.abilities.r:use(context, cast)
if cast.dir :dot ( context.allies_avg_pos - champ.pos ) > 0 then
cast.dir = - cast.dir
end
champ:effect(dash.new(1600, cast.target):on_finish(function()
local kick_dir = - cast.dir :normalize ()
local kick_pos = cast.target.pos + kick_dir * 600
cast.target:effect(pull.new(1000, kick_pos))
damage:new(580, damage.PHYSICAL):deal(champ, cast.target)
end))
end

function champ.behaviour(ready, context)
if context.closest_dist < 125 + 100 then
champ.range = 125
champ.target = context.closest_enemy
else
champ.range = 1000+100
champ:change_movement(movement.PEEL)
end
end

  return champ
end

return lee_sin