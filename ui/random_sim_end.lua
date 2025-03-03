local component  = require("ui.badr")
local button     = require("ui.button")
local label      = require("ui.label")
local image      = require("ui.image")
local scroll_box = require("ui.scroll_box")
local ui         = require("ui.main")

local random_sim_end = {}

local function sort_by_win_rate(champs)
    local sorted = {}

    -- Convert dictionary to an array
    for _, champ in pairs(champs) do
        table.insert(sorted, champ)
    end

    -- Sort by win_rate in descending order
    table.sort(sorted, function(a, b)
        return a.win_rate > b.win_rate
    end)

    return sorted
end

function random_sim_end:__call(info)
    local champs = sort_by_win_rate(info.champs)
    local res = component { column = true, center = true }

    local width = 300
    local height = 30
    local icon_size = 35
    local padding = 10
    for _, champ in pairs(champs) do
        local row = component { row = true, center = true }
        row = row + image { image = champ.sprite, height = icon_size, width = icon_size, borderRadius = 2*icon_size, borderColor = ui.SEL_COL, borderWidth = 3 }
        row = row + component { width = padding }
        row = row + component { width = champ.win_rate * width, height = height, bg = ui.BLUE_COL, borderRadius = 5 }
        row = row + component { width = (1 - champ.win_rate) * width, height = height, bg = ui.RED_COL, borderRadius = 5 }
        row = row + label { text = tostring(champ.wins) .. " - " .. tostring(champ.losses), color = {1, 1, 1}, height = height, width = 140, font = love.graphics.newFont(component.FONT, 15) }
        row = row + label { text = string.format("%.1f", champ.win_rate * 100) .. "%", color = {1, 1, 1}, height = height, width = 110, font = love.graphics.newFont(component.FONT, 15) }
        res = res + row
    end
    res = scroll_box { height = 500, offsetTop = 10, offsetBot = 50 } + res
    res.height = 500
    return res
end

return setmetatable(random_sim_end, random_sim_end)