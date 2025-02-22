local effect = require("util.effect")
local slow = {}

function slow.new(duration, amount)
  local self = effect.new({ "slow" }, duration)
  self.amount = 1 - amount
  return self
end

return slow
