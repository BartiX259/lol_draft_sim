local effect = require("util.effect")
local root = {}

function root.new(duration)
  local self = effect.new({ "root" }, duration)
  return self
end

return root
