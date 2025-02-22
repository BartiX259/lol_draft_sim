local vec2 = require("util.vec2")

local distances = {}

-- Find the closest unit from `units` to a given `unit`
function distances.find_closest(unit, units)
  local closest_enemy = nil
  local closest_distance = math.huge

  for _, other in pairs(units) do
    if unit ~= other then
      local distance = (other.pos - unit.pos):magsqr()
      if distance < closest_distance then
        closest_distance = distance
        closest_enemy = other
      end
    end
  end

  return closest_enemy
end

-- Compute the average position of `units` (ones closer to `unit` have more influence)
function distances.weighted_position(unit, units)
  local total_weight = 0
  local weighted_pos = vec2.new(0, 0)

  for _, ally in pairs(units) do
    if ally ~= unit then
      local distance = (ally.pos - unit.pos):mag()
      local weight = 1 / (distance + 1)
      total_weight = total_weight + weight
      weighted_pos = weighted_pos + (ally.pos * weight)
    end
  end

  if total_weight > 0 then
    return weighted_pos / total_weight
  else
    return unit.pos -- Return self position if no allies found
  end
end

-- Compute how many `units` are in `range` of `unit`
function distances.in_range(unit, units, range)
  local count = 0
  for _,u in pairs(units) do
    if u.pos:distance(unit.pos) < range then
      count = count + 1
    end
  end
  return count
end

-- Return the list of units from `units` which are in `range` of `unit`
function distances.in_range_list(unit, units, range)
  local res = {}
  for _,u in pairs(units) do
    if u.pos:distance(unit.pos) < range then
      table.insert(res, u)
    end
  end
  return res
end

-- Find the closest and largest clump of `units` in a `clump_range` within the `range` of `unit`
function distances.find_clump(unit, units, range, clump_range)
  local best_count = 0
  local best_target = nil

  for _, candidate in pairs(distances.in_range_list(unit, units, range)) do
    local count = 0
    for _, other in pairs(units) do
      if other ~= candidate and other.pos:distance(candidate.pos) <= clump_range then
        count = count + 1
      end
    end

    if count > best_count then
      best_count = count
      best_target = candidate
    elseif count == best_count then
      if best_target == nil or candidate.pos:distance(unit.pos) < best_target.pos:distance(unit.pos) then
        best_target = candidate
      end
    end
  end

  return { count = best_count, target = best_target }
end

return distances
