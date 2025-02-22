local vec2 = require("util.vec2")

local targeted = {}
targeted.__index = targeted

-- Constructor
function targeted.new(ability, pos, target, size, velocity, color)
  return setmetatable(
    {
      pos = pos,
      target = target,
      size = size,
      velocity = velocity,
      ability = ability,
      color = color,
      hit_cols = {},
    },
    targeted)
end

function targeted:update(dt)
  local ds = self.velocity * dt
  if self.pos:distance(self.target.pos) < ds then
    self.ability:hit(self.target)
    return true
  end
  local dir = (self.target.pos - self.pos):normalize()
  self.pos = self.pos + dir * ds
  return false
end

-- Cant dodge this :)
function targeted:dodge_dir(champ)
  return vec2.new(0, 0)
end

function targeted:draw()
  love.graphics.setColor(self.color)
  love.graphics.circle("fill", self.pos.x, self.pos.y, self.size / 2)
end

return targeted
