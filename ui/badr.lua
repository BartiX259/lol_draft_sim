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

badr.FONT = "assets/Nexa-Heavy.ttf"

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
  if type(component) ~= "table" or component == nil then return self end

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
          if component.width <= self.width then
            local target = (self.width - component.width) / 2
            component:updatePosition(target - component.x, 0)
          else
            for _, child in ipairs(self.children) do
              local target = (component.width - child.width) / 2
              child:updatePosition(target - child.x, 0)
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
          if component.height <= self.height then
            local target = (self.height - component.height) / 2
            component:updatePosition(0, target - component.y)
          else
            for _, child in ipairs(self.children) do
              local target = (component.height - child.height) / 2
              child:updatePosition(0, target - child.y)
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
  if type(component) ~= "table" or component == nil then return self end
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
    if not self.visible then return end

    for _, child in ipairs(self.children) do
        local width = child.borderWidth or 0
        local offset = width / 2

        if child.borderColor and width > 0 then
            love.graphics.setColor(child.borderColor)
            love.graphics.rectangle("fill", child.x - offset, child.y - offset, child.width + width, child.height + width,
                child.borderRadius, child.borderRadius)
        end
        if child.borderRadius then
            love.graphics.stencil(function()
                love.graphics.rectangle("fill", child.x, child.y, child.width, child.height, child.borderRadius,
                    child.borderRadius)
            end, "replace", 1)
            love.graphics.setStencilTest("equal", 1)
        end
        if child.bg then
            love.graphics.setColor(child.bg)
            love.graphics.rectangle("fill", child.x, child.y, child.width, child.height, child.borderRadius,
                child.borderRadius)
        end

        child:draw()

        if child.borderRadius then
            love.graphics.setStencilTest()
        end
    end

    for _, blend in ipairs(self.blends) do
        blend:draw()
    end
end

function badr:fitScreen(scale)
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()

  local scaleX = screenWidth / self.width
  local scaleY = screenHeight / self.height

  local scaleFactor = math.min(scaleX, scaleY) * scale

  local targetX = (screenWidth - self.width * scaleFactor) * 0.5
  local targetY = (screenHeight - self.height * scaleFactor) * 0.5

  if self.x ~= targetX or self.y ~= targetY then
    self:updatePosition(targetX - self.x, targetY - self.y)
  end
  if math.abs(scaleFactor - 1) > 0.001 then
    self:scale(scaleFactor)
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

function badr:scale(value)
  self.x = self.x * value
  self.y = self.y * value
  self.width = self.width * value
  self.height = self.height * value
  for _, child in ipairs(self.children) do
    child:scale(value)
  end
  for _, blend in ipairs(self.blends) do
    blend:scale(value)
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

return setmetatable({ new = badr.new, FONT = badr.FONT }, {
  __call = function(t, ...)
    return badr:new(...)
  end,
})
