local effect = require("util.effect")
local fly = {}

function fly.new(duration, channel)
  local self = effect.new({ "root", "silence" }, duration)

  function self:tick(context)
    if self.size == nil then
        self.size = context.champ.size
    end
    if self.elapsed >= channel then
        context.champ.size = 0
    else
        context.champ.size = self.size * (1 - self.elapsed / channel)
    end
    local res = self:base_tick(context)
    if res then
        context.champ.size = self.size
    end
    return res
  end

  return self
end

return fly
