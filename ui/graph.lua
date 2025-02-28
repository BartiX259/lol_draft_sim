local component = require("ui.badr")
local button    = require("ui.button")
local label     = require("ui.label")
local image     = require("ui.image")
local ui        = require("ui.main")

local graph    = {}

function graph:__call(key, blue_team, red_team)
    local max = 0.01
    for _, team in ipairs({ blue_team, red_team }) do
        for _, champ in pairs(team) do
            if champ[key] > max then
                max = champ[key]
            end
        end
    end
    local i, blue = next(blue_team, nil)
    local j, red = next(red_team, nil)
    local res = component { column = true, gap = 30 }
    local width = 300
    local w2 = width / 2
    local height = 30
    local icon_size = 35
    local padding = 10
    while blue or red do
        local row = component { row = true, gap = 0, center = true }
        local fill = w2 + icon_size + padding
        if blue then
            local w = w2 * blue[key] / max
            row = row + image { image = blue.sprite, height = icon_size, width = icon_size, borderRadius = 2*icon_size, borderColor = ui.BLUE_COL, borderWidth = 3 }
            row = row + component { width = padding }
            row = row + component { width = w, height = height, bg = ui.BLUE_COL, borderRadius = 5 }
            fill = fill - w - icon_size
            i, blue = next(blue_team, i)
        end
        row = row + component { width = fill }
        if red then
            local w = w2 * red[key] / max
            row = row + component { width = w2 - w - padding }
            row = row + component { width = w, height = height, bg = ui.RED_COL, borderRadius = 5 }
            row = row + component { width = padding }
            row = row + image { image = red.sprite, height = icon_size, width = icon_size, borderRadius = 2*icon_size, borderColor = ui.RED_COL, borderWidth = 3 }
            j, red = next(red_team, j)
        end
        res = res + row
    end
    -- res = component { row = true, gap = 30, center = true } + res
    return res
end

return setmetatable(graph, graph)