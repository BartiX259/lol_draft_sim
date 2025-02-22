local ability = {}

function ability:new(cd)
  return setmetatable({
    cd = cd,
    timer = 0,
  }, { __index = self })
end

function ability:cast()
  return nil
end

function ability:tick(dt)
  self.timer = self.timer - dt

  -- Change value when timer runs out
  if self.timer <= 0 then
    return true
  end
  return false
end

function ability:join(ability)
  self.joined = ability
  return self
end


return setmetatable(ability, ability)
