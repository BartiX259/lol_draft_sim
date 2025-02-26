local component = require("ui.badr")

-- Converts a hex color to RGBA
local function Hex(hex, alpha)
    return {
        tonumber(string.sub(hex, 2, 3), 16) / 256,
        tonumber(string.sub(hex, 4, 5), 16) / 256,
        tonumber(string.sub(hex, 6, 7), 16) / 256,
        alpha or 1
    }
end

return function(props)
    local font = props.font or love.graphics.getFont()
    local originalFontSize = font:getHeight()
    local padding = {
        horizontal = (props.leftPadding or 12) + (props.rightPadding or 12),
        vertical = (props.topPadding or 8) + (props.bottomPadding or 8)
    }
    local originalWidth = math.max(props.width or 0, font:getWidth(props.text) + padding.horizontal)
    local originalHeight = math.max(props.height or 0, originalFontSize + padding.vertical)

    return component {
        text = props.text or "Button",
        id = props.id or tostring(love.timer.getTime()),
        x = props.x or 0,
        y = props.y or 0,
        originalWidth = originalWidth,
        originalHeight = originalHeight,
        width = originalWidth,
        height = originalHeight,
        font = font,
        scaleFactor = 1, -- Tracks scaling factor
        -- Colors
        opacity = props.opacity or 1,
        backgroundColor = props.backgroundColor or Hex("#DBE2EF"),
        hoverColor = props.hoverColor or Hex("#3F72AF"),
        textColor = props.textColor or Hex("#112D4E"),
        borderColor = props.borderColor or { 1, 1, 1 },
        -- Styles
        cornerRadius = props.cornerRadius or 4,
        borderWidth = props.borderWidth or 0,
        border = props.border or false,
        -- Events
        onClick = props.onClick,
        onRightClick = props.onRightClick,
        onHover = props.onHover,
        disabled = props.disabled or false,
        onUpdate = function(self)
            if love.mouse.isDown(1) then
                if self.mousePressed == false and self:isMouseInside() and self.parent.visible then
                    self.mousePressed = true
                    if props.onClick then self:onClick() end
                end
            else
                self.mousePressed = false
            end
            if love.mouse.isDown(2) then
                if self.rightPressed == false and self:isMouseInside() and self.parent.visible then
                    self.rightPressed = true
                    if props.onRightClick then self:onRightClick() end
                end
            else
                self.rightPressed = false
            end
        end,
        -- Scale function
        scale = function(self, value)
            self.scaleFactor = self.scaleFactor * value

            -- Scale dimensions
            self.width = self.originalWidth * self.scaleFactor
            self.height = self.originalHeight * self.scaleFactor

            -- Scale position
            self.x = self.x * value
            self.y = self.y * value

            -- Update font size
            local newFontSize = math.floor(originalFontSize * self.scaleFactor)
            if newFontSize > 0 then
                self.font = love.graphics.newFont(newFontSize)
            end
        end,
        -- Draw function
        draw = function(self)
            if not self.visible then return end
            love.graphics.setFont(self.font)

            -- Border
            if self.border then
                love.graphics.setColor(self.borderColor)
                love.graphics.setLineWidth(self.borderWidth)
                love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.cornerRadius)
            end

            -- Button background color
            local color = self:isMouseInside() and self.hoverColor or self.backgroundColor
            love.graphics.setColor(color[1], color[2], color[3], self.opacity)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.cornerRadius)

            -- Text
            love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3], self.opacity)
            love.graphics.printf(self.text, self.x, self.y + (self.height - self.font:getHeight()) / 2, self.width, "center")

            love.graphics.setColor(1, 1, 1) -- Reset color
        end
    }
end
