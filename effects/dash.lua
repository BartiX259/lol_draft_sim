local pull = require("effects.pull")
local dash = {}

function dash.new(speed, towards)
  local self = pull.new(speed, towards)
  self.tags["dash"] = true
  return self
end

return dash
