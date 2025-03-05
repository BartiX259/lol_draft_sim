local component = require("ui.badr")

local function getOffsetX(options, width, fontWidth)
    return options.right and (width - fontWidth - 2*options.padding) or options.center and ((width - fontWidth) / 2) or 0
end

local function search_bar(options)
    options.text = options.text or ""
    local font = options.font or love.graphics.getFont()
    local originalWidth = math.max(options.width or 0, font:getWidth(options.text))
    local originalSize = math.max(options.height or 0, font:getHeight(options.text))
    local color = options.color or { 1, 1, 1 }
    options.padding = options.padding or 5
    options.placeholder = options.placeholder or "Type to search"

    return component {
        text = options.text,
        visible = options.visible or true,
        id = options.id,
        bg = options.bg,
        borderRadius = options.borderRadius,
        borderColor = options.borderColor,
        borderWidth = options.borderWidth,
        x = options.x or 0,
        y = options.y or 0,
        --
        max_count = options.max_count or 20,
        callback = options.callback or nil,
        placeholder = options.placeholder,
        placeholderColor = options.placeholderColor or { 0.5, 0.5, 0.5, 0.5 },
        placeholderHalfWidth = font:getWidth(options.placeholder) / 2,
        width = originalWidth + 2 * options.padding,
        height = originalSize + 2 * options.padding,
        padding = options.padding,
        font = font,
        offsetX = getOffsetX(options, originalWidth, font:getWidth(options.text)),
        scaleFactor = 1,
        textUpdate = function(self)
            if self.callback then
                self.callback(self.text)
            end
            self:scale(1)
        end,
        onUpdate = function(self)
            if component.events.text ~= nil and string.len(self.text) < self.max_count then
                self.text = self.text .. component.events.text
                component.events.text = nil
                self:textUpdate()
            end
            if component.events.key == "backspace" and string.len(self.text) >= 0 then
                self.text = self.text:sub(1, -2)
                component.events.key = nil
                self:textUpdate()
            end
        end,
        draw = function(self)
            if not self.visible then return end
            love.graphics.setFont(self.font)
            if string.len(self.text) > 0 then
                love.graphics.setColor(color)
                love.graphics.print(self.text, self.x + self.offsetX + self.padding, self.y + self.padding)
            else
                love.graphics.setColor(self.placeholderColor)
                love.graphics.print(self.placeholder, self.x + self.offsetX - self.placeholderHalfWidth + self.padding, self.y + self.padding)
            end
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
                self.font = love.graphics.newFont(component.font, newFontSize)
                self.placeholderHalfWidth = self.font:getWidth(options.placeholder) / 2
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

return search_bar
