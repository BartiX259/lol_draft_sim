local vec2 = {}
vec2.__index = vec2


-- Constructor
function vec2.new(x, y)
  return setmetatable({ x = x or 0, y = y or 0 }, vec2)
end
function vec2.from(vec)
  return setmetatable({ x = vec.x or 0, y = vec.y or 0 }, vec2)
end
function vec2.random()
  return setmetatable({ x = math.random(-1, 1), y = math.random(-1, 1) }, vec2)
end

-- Addition operator: v1 + v2
function vec2.__add(v1, v2)
  return vec2.new(v1.x + v2.x, v1.y + v2.y)
end

-- Subtraction operator: v1 - v2
function vec2.__sub(v1, v2)
  return vec2.new(v1.x - v2.x, v1.y - v2.y)
end

-- Multiplication operator: v * n
function vec2.__mul(v, n)
  return vec2.new(v.x * n, v.y * n)
end

-- Division operator: v / n
function vec2.__div(v, n)
  return vec2.new(v.x / n, v.y / n)
end

-- Negation operator: -v
function vec2.__unm(v)
  return vec2.new(-v.x, -v.y)
end

-- Normalize or return zero vector
function vec2:normalize()
  local length = math.sqrt(self.x * self.x + self.y * self.y)
  if length > 0 then
    return vec2.new(self.x / length, self.y / length)
  end
  return vec2.new(0, 0)
end

-- Distance between two vectors
function vec2:distance(other)
  local dx, dy = other.x - self.x, other.y - self.y
  return math.sqrt(dx * dx + dy * dy)
end

-- Square magnitude of vector
function vec2:magsqr()
  return self.x * self.x + self.y * self.y
end

-- Magnitude of vector
function vec2:mag()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

-- Dot product of two vectors
function vec2:dot(other)
  return self.x * other.x + self.y * other.y
end

-- Check if vector is zero
function vec2:is_zero()
  return self.x == 0 and self.y == 0
end

function vec2:rotate(deg)
  local cs = math.cos(deg)
  local sn = math.sin(deg)
  return vec2.new(cs * self.x - sn * self.y, sn * self.x + cs * self.y)
end

function vec2:softcap(cap)
  local mag = self:mag()
  return self:normalize() * (mag / (1 + math.abs(mag) / cap))
end

function vec2:softinv(cap)
  local mag = self:mag()
  if mag > cap * math.pi then
    return vec2.new(0, 0)
  end
  local cap2 = cap / 2
  return self:normalize() * (cap2 * math.cos(mag / cap) + cap2)
end

return vec2
