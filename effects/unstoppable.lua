local effect = require("util.effect")
local unstoppable = {}

function unstoppable.new(duration)
  local self = effect.new({ "unstoppable" }, duration)
  return self
end

return unstoppable
