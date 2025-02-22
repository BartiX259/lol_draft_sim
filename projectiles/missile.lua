local vec2 = require("util.vec2")
local collision = require("util.collision")

local missile = {}
missile.__index = missile

-- Constructor
function missile.new(ability, data)
  if getmetatable(data.from) == vec2 then
    data.pos = data.from
    data.from = nil
    if data.to then
      if getmetatable(data.to) == vec2 then
        local dir = data.to - data.pos
        data.dir = dir:normalize()
        data.range = dir:mag()
        data.to = nil
      else
        data.dir = nil
      end
    end
  end

  return setmetatable(
    {
      pos = data.pos,
      from = data.from,
      dir = data.dir,
      size = data.size,
      speed = data.speed,
      range = data.range or math.huge,
      stop_on_hit = data.stop_on_hit or false,
      colliders = data.colliders,
      to = data.to,
      ability = ability,
      next = data.next,
      color = data.color,
      hit_cols = data.hit_cols or {},
      traveled = 0
    },
    missile)
end

function missile:update(dt)
  if self.pos == nil and self.from ~= nil then
    self.pos = self.from.pos
    self.from = nil
  end
  if self.to then
    if getmetatable(self.to) == vec2 then
      local dir = self.to - self.pos
      self.dir = dir:normalize()
      self.range = dir:mag()
      self.to = nil
    else
      self.dir = nil
    end
  end
  local ds = self.speed * dt
  self.traveled = self.traveled + ds
  if self.dir then
    self.pos = self.pos + self.dir * ds
  end
  if self.colliders then
    if collision.projectile(self) then
      if self.stop_on_hit then
        return true
      end
    end
    if self.traveled >= self.range then
      return true
    end
  elseif self.to then
    if self.pos:distance(self.to.pos) < ds then
      self.ability:hit(self.to)
      return true
    end
  end
  if self.to then
    if self.to.health and self.to.health <= 0 then
      return true
    end
    local dir = (self.to.pos - self.pos):normalize()
    if self.pos:distance(self.to.pos) < ds then
      return true
    end
    self.pos = self.pos + dir * ds
  end
  return false
end

function missile:dodge_dir(champ)
  if not self.colliders then
    return vec2.new(0, 0)
  end
  if not self.pos then
    return vec2.new(0, 0)
  end
  if not self.dir and not self.to then
    return vec2.new(0, 0)
  end
  local dir = self.dir or (self.to.pos - self.pos):normalize()
  local to_champ = champ.pos - self.pos
  local proj_length = to_champ:dot(dir) -- Project `to_champ` onto skillshot direction
  local closest_point = self.pos + dir * proj_length
  local dist_to_path = (champ.pos - closest_point):mag()

  -- Check if dodge is needed
  local safety_buffer = 50
  local danger_distance = champ.size + self.size + safety_buffer
  if dist_to_path > danger_distance or proj_length < 0 or proj_length > self.range + safety_buffer then
    return vec2.new(0, 0) -- No dodge needed
  end

  -- Get perpendicular dodge directions
  local perp1 = vec2.new(dir.y, -dir.x)
  local perp2 = vec2.new(-dir.y, dir.x)

  -- Choose the dodge direction that moves away from the skillshot path
  local dodge_dir = perp1
  if (champ.pos + perp2 - closest_point):mag() > dist_to_path then
    dodge_dir = perp2
  end

  return dodge_dir:normalize()
end

function missile:draw()
  if self.pos == nil then
    return
  end
  love.graphics.setColor(self.color)
  love.graphics.circle("fill", self.pos.x, self.pos.y, self.size / 2)
end

return missile
