local vec2 = require("util.vec2")
local collision = require("util.collision")

local skillshot = {}
skillshot.__index = skillshot

-- Constructor
function skillshot.new(ability, pos, dir, size, velocity, range, stop_on_hit, colliders, color)
  return setmetatable(
    {
      pos = pos,
      dir = dir,
      size = size,
      velocity = velocity,
      range = range,
      stop_on_hit = stop_on_hit,
      colliders = colliders,
      ability = ability,
      color = color,
      hit_cols = {},
      traveled = 0
    },
    skillshot)
end

function skillshot:update(dt)
  local ds = self.velocity * dt
  self.traveled = self.traveled + ds
  self.pos = self.pos + self.dir * ds
  if collision.projectile(self) then
    if self.stop_on_hit then
      return true
    end
  end
  if self.traveled >= self.range then
    return true
  end
  return false
end


function skillshot:dodge_dir(champ)
  local to_champ = champ.pos - self.pos
  local proj_length = to_champ:dot(self.dir) -- Project `to_champ` onto skillshot direction
  local closest_point = self.pos + self.dir * proj_length
  local dist_to_path = (champ.pos - closest_point):mag()

  -- Check if dodge is needed
  local safety_buffer = 50
  local danger_distance = champ.size + self.size + safety_buffer
  if dist_to_path > danger_distance or proj_length < 0 or proj_length > self.range + safety_buffer then
    return vec2.new(0, 0) -- No dodge needed
  end

  -- Get perpendicular dodge directions
  local perp1 = vec2.new(self.dir.y, -self.dir.x)
  local perp2 = vec2.new(-self.dir.y, self.dir.x)

  -- Choose the dodge direction that moves away from the skillshot path
  local dodge_dir = perp1
  if (champ.pos + perp2 - closest_point):mag() > dist_to_path then
    dodge_dir = perp2
  end

  return dodge_dir:normalize()
end


function skillshot:draw()
  love.graphics.setColor(self.color)
  love.graphics.circle("fill", self.pos.x, self.pos.y, self.size / 2)
end

return skillshot
