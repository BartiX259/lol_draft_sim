local effect = require("util.effect")
local damage_buff = {}

function damage_buff.new(duration, amount)
  local self = effect.new({ "damage_buff" }, duration)
  self.amount = 1 + amount
  return self
end

return damage_buff
