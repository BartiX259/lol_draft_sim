local effect = require("util.effect")
local invulnerable = {}

function invulnerable.new(duration)
  local self = effect.new({ "invulnerable" }, duration)
  return self
end

return invulnerable
