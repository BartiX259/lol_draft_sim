local effect = require("util.effect")
local silence = {}

function silence.new(duration, amount)
  local self = effect.new({ "silence" }, duration)
  return self
end

return silence
