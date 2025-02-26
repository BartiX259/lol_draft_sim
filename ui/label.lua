local component = require("ui.badr")

local function label(options)
    local font = options.font or love.graphics.getFont()
    local font_width = font:getWidth(options.text or options)
    local width = options.width or font_width
    local color = options.color or { 0, 0, 0 }
    local offset_x = options.right and (width - font_width) or 0

    return component {
        text = options.text or options,
        visible = options.visible or true,
        id = options.id,
        bg = options.bg,
        --
        width = width,
        height = options.height or font:getHeight(options.text or options),
        onClick = options.onClick or nil,
        font = font,
        draw = function(self)
            if not self.visible then return end
            love.graphics.setFont(self.font)
            love.graphics.setColor({
                color[1], color[2], color[3], options.opacity
            })
            love.graphics.print(self.text, self.x + offset_x, self.y)
            love.graphics.setColor({ 1, 1, 1 })
        end,
    }
end

return label
