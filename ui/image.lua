local component = require("ui.badr")

local function image(options)
  local color = options.color or { 1, 1, 1 }

  return component {
    image = options.image,
    visible = options.visible or true,
    id = options.id,
    --
    width = options.width or options.image:getWidth(),
    height = options.height or options.image:getHeight(),
    draw = function(self)
      if not self.visible then return end
      love.graphics.setColor({
        color[1], color[2], color[3], options.opacity
      })
      love.graphics.draw(self.image, self.x, self.y + love.graphics:getFont():getHeight() / 2, 0, self.width / (self.image:getWidth()),
        self.height / (self.image:getHeight()), 0, self.image:getHeight() / 2)
    end,
  }
end

return image
