local effect = require("util.effect")
local airborne = {}

function airborne.new(duration)
  local self = effect.new({ "root", "silence", "airborne" }, duration)
  return self
end

return airborne
