local effect = require("util.effect")
local vec2 = require("util.vec2")
local suppress = {}

function suppress.new(duration, to)
  local self = effect.new({ "root", "silence", "suppress" }, duration)

  function self:tick(context)
    if self.offset == nil then
      self.offset = context.champ.pos - to.pos
      return false
    else
      if to == nil then
        return true
      end
      context.champ.pos = to.pos + self.offset
      return self:base_tick(context)
    end
  end

  return self
end

return suppress
