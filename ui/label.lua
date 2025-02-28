local component = require("ui.badr")

local function getOffsetX(options, width, fontWidth)
    return options.right and (width - fontWidth - 2*options.padding) or options.center and ((width - fontWidth) / 2) or 0
end

local function label(options)
    local font = options.font or love.graphics.getFont()
    local originalWidth = math.max(options.width or 0, font:getWidth(options.text))
    local originalSize = math.max(options.height or 0, font:getHeight(options.text))
    local color = options.color or { 0, 0, 0 }
    options.padding = options.padding or 5

    return component {
        text = options.text or options,
        visible = options.visible or true,
        id = options.id,
        bg = options.bg,
        borderRadius = options.borderRadius,
        borderColor = options.borderColor,
        borderWidth = options.borderWidth,
        --
        width = originalWidth + 2 * options.padding,
        height = originalSize + 2 * options.padding,
        padding = options.padding,
        font = font,
        offsetX = getOffsetX(options, originalWidth, font:getWidth(options.text)),
        scaleFactor = 1,
        draw = function(self)
            if not self.visible then return end
            love.graphics.setFont(self.font)
            love.graphics.setColor(color)
            love.graphics.print(self.text, self.x + self.offsetX + self.padding, self.y + self.padding)
            love.graphics.setColor({ 1, 1, 1 })
        end,
        scale = function(self, value)
            self.scaleFactor = self.scaleFactor * value
            self.x = self.x * value
            self.y = self.y * value
            self.width = self.width * value
            self.height = self.height * value
            self.padding = self.padding * value
            options.padding = self.padding
            local newFontSize = math.floor(originalSize * self.scaleFactor)
            if newFontSize > 0 then
                self.font = love.graphics.newFont(component.FONT, newFontSize)
                local fontWidth = self.font:getWidth(self.text)
                if fontWidth > self.width then
                    self.x = self.x - (fontWidth - self.width) / 2 - self.padding
                    self.width = fontWidth + 2 * self.padding
                end
                local fontHeight = self.font:getHeight(self.text)
                if fontHeight > self.height then
                    self.y = self.y - (fontHeight - self.height) / 2 - self.padding
                    self.height = fontHeight + 2 * self.padding
                end
                self.offsetX = getOffsetX(options, self.width, fontWidth)
            end
        end
    }
end

return label
