local effect = require("util.effect")
local stun = {}

function stun.new(duration)
  local self = effect.new({ "stun" }, duration)
  return self
end

return stun
