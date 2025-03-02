local vec2 = require("util.vec2")
local random = require("util.random")

local champion = {}
champion.__index = champion

-- Constructor
function champion.new(data)
  local self = setmetatable({}, champion)
  self.pos = vec2.new(data.x or 0, data.y or 0)
  self.health = data.health or data.max_health or 100
  self.max_health = data.max_health or data.health or 100
  self.size = data.size or 100
  self.ms = data.ms or 395
  self.range = data.range or 500
  self.armor = data.armor or 50
  self.mr = data.mr or 50
  -- self.movement_scripts = table.shallow_copy(data.movement) or {}
  self.movement_scripts = {}
  self.sprite = love.graphics.newImage("assets/champions/" .. data.sprite)
  self.name = data.sprite
  self.effects = {}
  self.move_dir = vec2.new(0, 0)
  self.random = random:new()
  self.damage_dealt = 0

  -- Initialize abilities
  self.abilities = data.abilities or {}

  return self
end

function champion:move(context)
  local dir = vec2.new(0, 0)
  -- print("---" .. context.champ.name)
  for script, mult in pairs(self.movement_scripts) do
    local script_dir = require("movement." .. script)(context) * mult
    -- if script == "dodge" and script_dir.x ~= 0 then
    -- print(script .. ": [" .. script_dir.x .. ", " .. script_dir.y .. "], mult = " ..tostring(mult))
    -- end
    dir = dir + script_dir
  end
  self.move_dir = dir
end

function champion:on_hit(damage)
  self.health = self.health - damage:calculate(self)
end

function champion:change_movement(scripts)
  self.target = nil
  local changed = false
  for script, value in pairs(scripts) do
    if self.movement_scripts[script] ~= value then
      changed = true
      self.movement_scripts[script] = value
    end
  end
  if changed then
    -- print("CHANGE: " .. self.name .. " -- " .. self.movement_scripts["engage"])
    self.random.timer = math.min(0.15, self.random.timer)
  end
end

function champion:effect(effect)
  if self:has_effect("unstoppable") and not effect.tags["dash"] and (effect.tags["root"] or effect.tags["silence"] or effect.tags["slow"]) then
    return
  end
  if effect.tags["pull"] or effect.tags["root"] then -- Multiple pulls are bad
    self:del_effect("pull")
  end
  
  table.insert(self.effects, effect)
end

function champion:has_effect(tag)
  for _, effect in pairs(self.effects) do
    if effect.tags[tag] then
      return true
    end
  end
  return false
end

function champion:get_effects(tag)
  local res = {}
  for id, effect in pairs(self.effects) do
    if effect.tags[tag] then
      res[id] = effect
    end
  end
  return res
end

function champion:del_effect(tag)
  for id, effect in pairs(self.effects) do
    if effect.tags[tag] then
      table.remove(self.effects, id)
    end
  end
end

function champion:prio()
  local ehp = self.health * (1 + 0.01 * self.armor) * (1 + 0.01 * self.mr) / 1000
  return ehp * ehp
end

return champion
