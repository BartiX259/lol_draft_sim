local component = require("ui.badr")

local child_y = 0

local function scroll_box(options)
    return component {
        column = true, center = true,
        onUpdate = function(self)
            if self:isMouseInside() and component.WHEEL[1] ~= 0 then
                local delta = component.WHEEL[1] * 30
                if child_y + delta <= 0 and -(child_y + delta) <= self.children[1].height - options.height then
                    self:updatePosition(0, delta)
                    child_y = child_y + delta
                    self.y = self.y - delta
                end
                component.WHEEL[1] = 0
            end
        end,
        draw = function(self)
            love.graphics.intersectScissor(self.x - 50, self.y - (options.offsetTop or 0), self.width + 100, options.height + (options.offsetBot or 0))

            for _, child in ipairs(self.children) do
                child:draw()
            end

            love.graphics.setScissor()
        end,
        scale = function(self, value)
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
            options.height = options.height * value
            child_y = child_y * value
        end
    }
end

return scroll_box
