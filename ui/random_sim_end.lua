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

local function calc_win_rate_probability(wins, losses, threshold)
    local function tanh(x)
        local exp_plus = math.exp(x)
        local exp_minus = math.exp(-x)
        return (exp_plus - exp_minus) / (exp_plus + exp_minus)
    end
    -- Default overdispersion if not provided
    local overdispersion_factor = 20
    
    local total_games = wins + losses
    local observed_win_rate = wins / total_games
    
    -- Apply overdispersion by shrinking the effective sample size
    local effective_sample_size = total_games / overdispersion_factor
    local effective_wins = observed_win_rate * effective_sample_size
    local effective_losses = effective_sample_size - effective_wins
    
    -- Add a weak prior (equivalent to 1 prior win and 1 prior loss)
    local alpha = effective_wins + 1
    local beta = effective_losses + 1
    
    -- Calculate mean and variance of the Beta distribution
    local mean = alpha / (alpha + beta)
    local variance = (alpha * beta) / ((alpha + beta)^2 * (alpha + beta + 1))
    local std_dev = math.sqrt(variance)
    
    -- Calculate probability using normal approximation to Beta distribution
    -- For the threshold probability: P(p > threshold)
    local z = (threshold - mean) / std_dev
    
    -- Simple approximation to the normal CDF
    local probability = 0.5 * (1 - tanh(z / math.sqrt(2)))
    
    return probability
end

function random_sim_end:__call(info)
    local champs = sort_by_win_rate(info.champs)
    local res = component { column = true, center = true }

    local width = 300
    local height = 30
    local icon_size = 35
    local padding = 10
    local font = love.graphics.newFont(component.FONT, 15)
    for _, champ in pairs(champs) do
        local row = component { row = true, center = true }
        row = row + image { image = champ.sprite, height = icon_size, width = icon_size, borderRadius = 2*icon_size, borderColor = ui.SEL_COL, borderWidth = 3 }
        row = row + component { width = padding }
        row = row + component { width = champ.win_rate * width, height = height, bg = ui.BLUE_COL, borderRadius = 5 }
        row = row + component { width = (1 - champ.win_rate) * width, height = height, bg = ui.RED_COL, borderRadius = 5 }
        row = row + label { text = tostring(champ.wins) .. " - " .. tostring(champ.losses), color = {1, 1, 1}, height = height, width = 140, font = font }
        row = row + label { text = string.format("%.1f", champ.win_rate * 100) .. "%", color = {1, 1, 1}, height = height, width = 130, font = font }
        local prob = math.max(calc_win_rate_probability(champ.wins, champ.losses, 0.55), 1 - calc_win_rate_probability(champ.wins, champ.losses, 0.45))
        row = row + label { text = string.format("%.1f", prob * 100) .. "%", color = {1, 1, 1}, height = height, width = 130, font = font }
        res = res + row
    end
    res = scroll_box { height = 500, offsetTop = 10, offsetBot = 50 } + res
    res.height = 500
    local desc_row = component { row = true, center = true }
        + label { text = "Simulation result", width = icon_size + padding + width + 140, font = font, color = {1, 1, 1} }
        + label { text = "Win rate", width = 130, font = font, color = {1, 1, 1} }
        + label { text = "Imbalanced %", width = 130, font = font, color = {1, 1, 1} }
    res = component { column = true, center = true, gap = 20 } + desc_row + res
    return res
end

return setmetatable(random_sim_end, random_sim_end)