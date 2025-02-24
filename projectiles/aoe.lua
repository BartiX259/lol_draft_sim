local vec2 = require("util.vec2")
local collision = require("util.collision")

local aoe = {}
aoe.__index = aoe

-- Constructor
function aoe:new(ability, data)
  if getmetatable(data.at) == vec2 then
    data.pos = data.at
    data.at = nil
  end
  if data.at == nil and data.follow ~= nil then
    data.at = data.follow
  end
  return setmetatable(
    {
      pos = data.pos,
      at = data.at,
      deploy_time = data.deploy_time or 0,
      size = data.size,
      colliders = data.colliders,
      ability = ability,
      persist_time = data.persist_time or 0.5,
      follow = data.follow,
      hard_follow = data.hard_follow or false,
      color = data.color,
      hit_cols = data.hit_cols or {},
      after_hit = false,
      cur_time = 0
    },
    {__index = self})
end

function aoe:update(dt)
  if self.pos == nil and self.at ~= nil then
    self.pos = self.at.pos
  end
  self.cur_time = self.cur_time + dt
  if self.follow ~= nil then
    self.pos = self.follow.pos
    if self.hard_follow and self.follow.health <= 0 then
      self.next = nil
      return true
    end
  end

  if not self.after_hit and self.cur_time >= self.deploy_time then
    self.after_hit = true
    if self.impact then
      self.impact()
    end
    collision.projectile(self)
  end
  if self.cur_time >= self.deploy_time + self.persist_time then
    return true
  end
  return false
end

function aoe:dodge_dir(champ)
  if self.pos == nil then
    return vec2.new(0, 0)
  end
  local to_champ = champ.pos - self.pos
  local dist = to_champ:mag()

  local danger_radius = (self.size + champ.size) / 2 + 30
  if dist > danger_radius or self.cur_time >= self.deploy_time then
    return vec2.new(0, 0) -- No dodge needed
  end

  return to_champ:normalize()
end

function aoe:on_finish(func)
  self.after = func
  return self
end
function aoe:on_impact(func)
  self.impact = func
  return self
end
function aoe:draw()
  if self.pos == nil then
    return
  end
  love.graphics.setColor(self.color)
  local scale = 1
  if self.deploy_time > 0 and self.cur_time < self.deploy_time then
    scale = self.cur_time / self.deploy_time
  end
  love.graphics.circle("fill", self.pos.x, self.pos.y, scale * self.size / 2)
end

return aoe
