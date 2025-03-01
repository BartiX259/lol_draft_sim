local ability = require("util.ability")
local distances = require("util.distances")
local big = {}

function big.new(cd, range)
  local self = ability:new(cd)

  function self:cast(context)
    local min_ehp = math.huge
    local target
    for _, enemy in pairs(distances.in_range_list(context.champ, context.enemies, range)) do
        local ehp = enemy.health * (1 + 0.01 * enemy.armor) * (1 + 0.01 * enemy.mr)
        if ehp < min_ehp then
            min_ehp = ehp
            target = enemy
        end
    end
    if target == nil then
        return nil
    end
    local dir = target.pos - context.champ.pos
    local mag = dir:mag()
    local delim = (min_ehp / 1000) * (min_ehp / 1000) * mag/range
    if delim < 10 then
        return {
            target = target,
            pos = target.pos,
            dir = dir:normalize(),
            mag = mag
        }
    end
    return nil
  end

  return self
end

return setmetatable(big, big)
