local effect = require("util.effect")
local vec2 = require("util.vec2")
local pull = {}

function pull.new(speed, towards)
  local self = effect.new({ "root", "silence", "pull" }, 0)
  self.speed = speed
  if towards.pos ~= nil then
    self.unit = towards
  elseif getmetatable(towards) == vec2 then
    self.pos = towards
  end

  function self:tick(context)
    if self.unit ~= nil then
      self.pos = self.unit.pos
    end
    local dir = self.pos - context.champ.pos
    context.champ.pos = context.champ.pos + dir:normalize() * self.speed * context.dt
    if self.first_dir == nil then
      self.first_dir = dir
    elseif dir:dot(self.first_dir) <= 0 then
      return true
    end
    if context.champ.pos:distance(self.pos) < 1 then
      return true
    end
    return false
  end

  return self
end

return pull
