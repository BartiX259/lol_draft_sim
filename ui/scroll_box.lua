local component = require("ui.badr")

local function scroll_box(options)
    return component {
        column = true, center = true,
        scaleFactor = 1,
        child_y = 0,
        onUpdate = function(self)
            if self:isMouseInside() and component.events.wheel ~= 0 then
                local delta = component.events.wheel * 30
                -- Ensure we don't scroll above the top limit
                if self.child_y + delta > 0 then
                    delta = -self.child_y
                end
                -- Ensure we don't scroll past the bottom limit
                local maxScroll = self.children[1].height - options.height
                if self.child_y + delta < -maxScroll then
                    delta = -maxScroll - self.child_y
                end
                if delta ~= 0 then
                    self:updatePosition(0, delta)
                    self.child_y = self.child_y + delta
                    self.y = self.y - delta
                end
                component.events.wheel = 0
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
            self.scaleFactor = self.scaleFactor * value
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
            if options.offsetTop then
                options.offsetTop = options.offsetTop * value
            end
            if options.offsetBot then
                options.offsetBot = options.offsetBot * value
            end
            self.child_y = self.child_y * value
        end
    }
end

return scroll_box
