local effect = require("util.effect")
local airborne = {}

function airborne.new(duration)
  local self = effect.new({ "stun", "airborne" }, duration)
  return self
end

return airborne
