local effect = require("util.effect")
local shield = {}

function shield.new(duration, amount)
  local self = effect.new({ "shield" }, duration)
  self.amount = amount
  return self
end

return shield
