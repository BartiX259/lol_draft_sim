local random = {}

function random:new()
  return setmetatable({
    value = 0,
    timer = 0,
  }, { __index = self })
end

function random:tick(dt)
  self.timer = self.timer - dt

  -- Change value when timer runs out
  if self.timer <= 0 then
    self.value = math.random()
    self.timer = math.random(0.15, 0.3)
    return true
  end
  return false
end


return setmetatable(random, random)
