local component = require("ui.badr")

local function image(options)
  local color = options.color or { 1, 1, 1 }
  local image = options.image
  if type(image) == "table" then
    image = image.image
  end

  return component {
    image = options.image,
    visible = options.visible or true,
    id = options.id,
    --
    width = options.width or image:getWidth(),
    height = options.height or image:getHeight(),
    draw = function(self)
      if not self.visible then return end
      love.graphics.setColor({
        color[1], color[2], color[3], options.opacity
      })
      local image = self.image
      if type(image) == "table" then
        image = image.image
      end
      if options.center then
        love.graphics.draw(image, self.x, self.y + love.graphics:getFont():getHeight() / 2, 0, self.width / (image:getWidth()), self.height / (image:getHeight()), 0, image:getHeight() / 2)
      else
        love.graphics.draw(image, self.x, self.y, 0, self.width / (image:getWidth()), self.height / (image:getHeight()))
      end
    end,
  }
end

return image
