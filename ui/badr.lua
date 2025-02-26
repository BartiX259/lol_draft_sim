--
-- Badr
--
-- Copyright (c) 2024 Nabeel20
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
local badr = {}
badr.__index = badr

function badr:new(t)
  t = t or {}
  local _default = {
    x = 0,
    y = 0,
    height = 0,
    width = 0,
    parent = { x = 0, y = 0, visible = true },
    id = tostring(love.timer.getTime()),
    visible = true,
    children = {},
    blends = {}
  }
  for key, value in pairs(t) do
    _default[key] = value
  end
  return setmetatable(_default, badr)
end

function badr.__add(self, component)
  if type(component) ~= "table" or component == nil then return end

  component.parent = self
  component.x = self.x + component.x
  component.y = self.y + component.y

  local childrenSize = { width = 0, hight = 0 }
  for _, child in ipairs(self.children) do
    childrenSize.width = childrenSize.width + child.width;
    childrenSize.hight = childrenSize.hight + child.height
  end

  local gap = self.gap or 0
  local lastChild = self.children[#self.children] or {}

  if self.column then
    component.y = (lastChild.height or 0) + (lastChild.y or self.y)
    if #self.children > 0 then
      component.y = component.y + gap
        if self.center then
          if component.width < self.width then
            component.x = (self.width - component.width) / 2
          else
            for _, child in ipairs(self.children) do
              child.x = (component.width - child.width) / 2
            end
          end
        end
    end
    self.height = math.max(self.height, childrenSize.hight + component.height + gap * #self.children)
    self.width = math.max(self.width, component.width)
  end
  if self.row then
    component.x = (lastChild.width or 0) + (lastChild.x or self.x)
    if #self.children > 0 then
      component.x = component.x + gap
      if self.center then
          if component.height < self.height then
            component.y = (self.height - component.height) / 2
          else
            for _, child in ipairs(self.children) do
              child.y = (component.height - child.height) / 2
            end
          end
        end
    end
    self.width = math.max(self.width, childrenSize.width + component.width + gap * #self.children)
    self.height = math.max(self.height, component.height)
  end

  if #component.children > 0 then
    for _, child in ipairs(component.children) do
      child:updatePosition(component.x, component.y)
    end
    for _, blend in ipairs(component.blends) do
      blend:updatePosition(component.x, component.y)
    end
  end
  table.insert(self.children, component)
  return self
end

function badr.__mul(self, component)
  if type(component) ~= "table" or component == nil then return end
  component:updatePosition((self.width - component.width) / 2, 0)
  table.insert(self.blends, component)
  return self
end

-- Remove child
function badr.__sub(self, component)
  if self % component.id then
    for index, child in ipairs(self.children) do
      if child.id == component.id then
        table.remove(self.children, index)
      end
    end
  end
  return self
end

-- Returns child with specific id
function badr.__mod(self, id)
  assert(type(id) == "string", 'Badar; Provided id must be a string.')
  for _, child in ipairs(self.children) do
    if child.id == id then
      return child
    end
  end
end

function badr:isMouseInside()
  local mouseX, mouseY = love.mouse.getPosition()
  return mouseX >= self.x and mouseX <= self.x + self.width and
      mouseY >= self.y and
      mouseY <= self.y + self.height
end

function badr:draw()
  if not self.visible then return end;
  for _, child in ipairs(self.children) do
    if child.bg then
      love.graphics.setColor(child.bg)
      love.graphics.rectangle("fill", child.x + (child.bgOffset or 0), child.y, child.bgWidth or child.width, child.height)
    end
    child:draw()
  end
  for _, blend in ipairs(self.blends) do
    blend:draw()
  end
end

function badr:updatePosition(x, y)
  self.x = self.x + x
  self.y = self.y + y
  for _, child in ipairs(self.children) do
    child:updatePosition(x, y)
  end
  for _, blend in ipairs(self.blends) do
    blend:updatePosition(x, y)
  end
end

function badr:animate(props)
  props(self)
  for _, child in ipairs(self.children) do
    child:animate(props)
  end
end

function badr:update()
  if self.onUpdate then
    self:onUpdate()
  end
  for _, child in ipairs(self.children) do
    child:update()
  end
   for _, blend in ipairs(self.blends) do
    blend:update()
  end
end

return setmetatable({ new = badr.new }, {
  __call = function(t, ...)
    return badr:new(...)
  end,
})
