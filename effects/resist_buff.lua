local effect = require("util.effect")
local resist_buff = {}

function resist_buff.new(duration, amount)
  local self = effect.new({ "resist_buff" }, duration)
  self.applied = false
  
  function self:tick(context)
    if not self.applied then
        self.applied = true
        context.champ.armor = context.champ.armor + amount
        context.champ.mr = context.champ.mr + amount
    end
    local res = self:base_tick(context)
    if res then
        context.champ.armor = context.champ.armor - amount
        context.champ.mr = context.champ.mr - amount
    end
    return res
  end
  return self
end

return resist_buff
