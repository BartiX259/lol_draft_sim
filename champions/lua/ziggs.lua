local ranged_cast = require("abilities.ranged")
local ranged_aa_cast = require("abilities.ranged_aa")
local splash_cast = require("abilities.splash")
local aoe = require("projectiles.aoe")
local missile = require("projectiles.missile")
local champion = require("util.champion")
local damage = require("util.damage")
local movement = require("util.movement")

local ziggs = {}

-- Constructor
function ziggs.new(x, y)
  local champ = champion.new({ x = x, y = y,
    health = 1878,
    armor = 77.4,
    mr = 45.6,
    ms = 340,
    sprite = 'ziggs.jpg',
  })

  champ.abilities = {
    aa = ranged_aa_cast.new(1.5, 550, 335, { 0.8,0.5,0.2 }),
    q = ranged_cast.new(3.2, 1400),
    r = splash_cast.new(76, 5000, 525),
  }

function champ.abilities.aa:hit(target)
damage:new(335, damage.MAGIC):deal(champ, target)
end

function champ.abilities.q:use(context, cast)
local range = math.min ( 850 , cast.mag )
self.proj = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 180,
speed = 1700,
color = { 0.8,0.5,0.2 },
range = range,
from = champ.pos,
})
self.proj.after = function ()
context.spawn( aoe:new(self, { colliders = context.enemies,
size = 240,
color = { 0.8,0.5,0.2 },
deploy_time = 0.2,
at = self.proj.pos,
})
)
end
self.proj.next = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 180,
speed = 1700,
color = { 0.8,0.5,0.2 },
range = 300,
})
self.proj.next.after = function ()
context.spawn( aoe:new(self, { colliders = context.enemies,
size = 240,
color = { 0.8,0.5,0.2 },
deploy_time = 0.2,
at = self.proj.pos,
})
)
end
self.proj.next.next = missile.new(self, { dir = cast.dir,
colliders = nil,
size = 180,
speed = 1700,
color = { 0.8,0.5,0.2 },
range = 250,
})
self.proj.next.next.next = aoe:new(self, { colliders = context.enemies,
size = 240,
color = { 0.8,0.5,0.2 },
deploy_time = 0.2,
})
context.spawn( self.proj
)
end

function champ.abilities.q:hit(target)
damage:new(382.5, damage.MAGIC):deal(champ, target)
end

function champ.abilities.r:use(context, cast)
self.proj = aoe:new(self, { colliders = context.enemies,
size = 525,
color = { 0.8,0.5,0.2 },
deploy_time = 1.2,
at = cast.pos,
})
context.spawn( self.proj
)
end

function champ.abilities.r:hit(target)
damage:new(615, damage.MAGIC):deal(champ, target)
end

function champ.behaviour(ready, context)
champ.range = 1400
champ:change_movement(movement.PASSIVE)
end

  return champ
end

return ziggs