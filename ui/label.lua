local component = require("ui.badr")

local function getOffsetX(options, width, fontWidth)
    return options.right and (width - fontWidth - 2*options.padding) or options.center and ((width - fontWidth) / 2) or 0
end

local function label(options)
    local font = options.font or love.graphics.getFont()
    local fontWidth = font:getWidth(options.text or options)
    local width = options.width or fontWidth
    local originalSize = options.height or font:getHeight(options.text or options)
    local color = options.color or { 0, 0, 0 }
    options.padding = options.padding or 5

    return component {
        text = options.text or options,
        visible = options.visible or true,
        id = options.id,
        bg = options.bg,
        --
        width = width + 2 * options.padding,
        height = originalSize + 2 * options.padding,
        padding = options.padding,
        onClick = options.onClick or nil,
        font = font,
        offsetX = getOffsetX(options, width, fontWidth),
        scaleFactor = 1,
        draw = function(self)
            if not self.visible then return end
            love.graphics.setFont(self.font)
            love.graphics.setColor({
                color[1], color[2], color[3], options.opacity
            })
            love.graphics.print(self.text, self.x + self.offsetX + self.padding, self.y + self.padding)
            love.graphics.setColor({ 1, 1, 1 })
        end,
        scale = function(self, value)
            self.x = self.x * value
            self.y = self.y * value
            self.width = self.width * value
            self.height = self.height * value
            self.padding = self.padding * value
            options.padding = self.padding
            self.scaleFactor = self.scaleFactor * value
            local newFontSize = math.floor(originalSize * self.scaleFactor)
            if newFontSize > 0 then
                self.font = love.graphics.newFont(newFontSize)
            end
            local fontWidth = self.font:getWidth(self.text)
            self.offsetX = getOffsetX(options, self.width, fontWidth)
        end
    }
end

return label
