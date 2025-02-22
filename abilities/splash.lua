local ability = require("util.ability")
local distances = require("util.distances")
local splash = {}

function splash.new(cd, range, size)
  local self = ability:new(cd)

  function self:cast(context)
    local clump = distances.find_clump(context.champ, context.enemies, range, size)
    local target = clump.target
    if target == nil then
      return nil
    end
    local dir = (target.pos - context.champ.pos)
    local mag = dir:mag()
    return {
      target = target,
      pos = target.pos,
      dir = dir:normalize(),
      mag = mag
    }
  end

  return self
end

return setmetatable(splash, splash)
