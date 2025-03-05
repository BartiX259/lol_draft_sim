local component = require("ui.badr")

return function(options)
    local font = options.font or love.graphics.getFont()
    local originalWidth = math.max(options.width or 0, font:getWidth(options.text))
    local originalSize = math.max(options.height or 0, font:getHeight(options.text))
    options.padding = options.padding or 0

    return component {
        text = options.text or "Button",
        id = options.id or tostring(love.timer.getTime()),
        x = options.x or 0,
        y = options.y or 0,
        padding = options.padding,
        borderRadius = options.borderRadius,
        borderColor = options.borderColor,
        borderWidth = options.borderWidth,
        width = originalWidth + 2 * options.padding,
        height = originalSize + 2 * options.padding,
        font = font,
        scaleFactor = 1, -- Tracks scaling factor
        -- Colors
        opacity = options.opacity or 1,
        backgroundColor = options.backgroundColor or {0.4, 0.38, 0.4},
        hoverColor = options.hoverColor or {0.3, 0.5, 0.4},
        textColor = options.textColor or {1, 1, 1},
        -- Events
        onClick = options.onClick,
        onRightClick = options.onRightClick,
        onHover = options.onHover,
        disabled = options.disabled or false,
        onUpdate = function(self)
            self.bg = self:isMouseInside() and self.hoverColor or self.backgroundColor
            if love.mouse.isDown(1) then
                if self.mousePressed == false and self:isMouseInside() and self.parent.visible then
                    self.mousePressed = true
                    if options.onClick then self:onClick() end
                end
                if not self:isMouseInside() and self.parent.visible then
                    self.mousePressed = false
                end
            else
                self.mousePressed = false
            end
            if love.mouse.isDown(2) then
                if self.rightPressed == false and self:isMouseInside() and self.parent.visible then
                    self.rightPressed = true
                    if options.onRightClick then self:onRightClick() end
                end
            else
                self.rightPressed = false
            end
        end,
        draw = function(self)
            if not self.visible then return end
            love.graphics.setFont(self.font)

            love.graphics.setColor(self.textColor)
            love.graphics.printf(self.text, self.x, self.y + (self.height - self.font:getHeight()) / 2, self.width, "center")

            love.graphics.setColor(1, 1, 1) -- Reset color
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
                self.font = love.graphics.newFont(component.font, newFontSize)
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
            end
        end
    }
end
