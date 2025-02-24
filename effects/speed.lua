local effect = require("util.effect")
local speed = {}

function speed.new(duration, amount)
  local self = effect.new({ "speed" }, duration)
  self.amount = 1 + amount
  return self
end

return speed
