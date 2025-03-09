local component  = require("ui.badr")
local button     = require("ui.button")
local label      = require("ui.label")
local image      = require("ui.image")
local scroll_box = require("ui.scroll_box")
local ui         = require("ui.main")

local find_best_end = {}

function find_best_end:__call(info)
    local res = component { column = true, center = true }

    local width = 300
    local height = 30
    local icon_size = 35
    local padding = 10
    local font = love.graphics.newFont(component.font, 15)
    for _, champ in pairs(info) do
        local row = component { row = true, center = true }
        row = row + image { image = champ.sprite, height = icon_size, width = icon_size, borderRadius = 2*icon_size, borderColor = ui.SEL_COL, borderWidth = 3 }
        row = row + component { width = padding }
        row = row + component { width = champ.win_rate * width, height = height, bg = ui.BLUE_COL, borderRadius = 5 }
        row = row + component { width = (1 - champ.win_rate) * width, height = height, bg = ui.RED_COL, borderRadius = 5 }
        row = row + label { text = tostring(champ.wins) .. " - " .. tostring(champ.plays - champ.wins), color = {1, 1, 1}, height = height, width = 140, font = font }
        row = row + label { text = string.format("%.1f", champ.win_rate * 100) .. "%", color = {1, 1, 1}, height = height, width = 130, font = font }
        res = res + row
    end
    res = scroll_box { height = 500, offsetTop = 10, offsetBot = 50 } + res
    res.height = 500
    local desc_row = component { row = true, center = true }
        + label { text = "Simulation result", width = icon_size + padding + width + 140, font = font, color = {1, 1, 1} }
        + label { text = "Win rate", width = 150, font = font, color = {1, 1, 1} }
    res = component { column = true, gap = 20 } + desc_row + res
        + component { height = 40 }
        + button { text = "Draft", hoverColor = ui.SEL_COL, onClick = function()
        ui.draft_mode()
      end }
    return res
end

return setmetatable(find_best_end, find_best_end)