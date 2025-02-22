local effect = {}
effect.__index = effect

function effect.new(tags, duration)
  local self = setmetatable({}, effect)
  self.tags = {}
  for _,tag in pairs(tags) do
    self.tags[tag] = true
  end
  self.duration = duration
  self.elapsed = 0
  return self
end

function effect:on_finish(func)
  self.on_finish_func = func
  return self
end

function effect:base_tick(context)
  self.elapsed = self.elapsed + context.dt
  if self.elapsed >= self.duration then
    return true
  end
  return false
end

function effect:tick(context)
  return self:base_tick(context)
end

return effect
