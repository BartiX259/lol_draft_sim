local champion = require("util.champion")
local missile = require("projectiles.missile")
local ranged = require("abilities.ranged")
local buff = require("abilities.buff")
local damage = require("util.damage")
local movement = require("util.movement")
local vec2 = require("util.vec2")

local lulu = {}

local Q = {
  CD = 5.1,
  DAMAGE = 156,
  RANGE = 925,
  SPEED = 1600,
  SIZE = 120,
  SLOW_DURATION = 1,
  SLOW_AMOUNT = 0.2,
}

local WE = { -- Combined W/E for allies.
  CD = 6,
  SHIELD_AMOUNT = 303,
  SHIELD_DURATION = 2.5,
  DAMAGE_BUFF_AMOUNT = 0.3,
  DAMAGE_BUFF_DURATION = 3.5,
  RANGE = 650,
  SPEED_BUFF_AMOUNT = 0.25,
  SPEED_BUFF_DURATION = 3.5
}

function lulu.new(x, y)
  local champ = champion.new({
    x = x,
    y = y,
    health = 1602.4,
    armor = 70,
    mr = 41,
    ms = 375,
    sprite = "lulu.jpg",
  })

  champ.abilities = {
    q = ranged.new(Q.CD, Q.RANGE),
    we = buff.new(WE.CD, WE.RANGE),
  }

  -- Behaviour
  function champ.behaviour()
    champ.range = Q.RANGE
    champ:change_movement(movement.PEEL)
  end

  -- Glitterlance (Q)
  function champ.abilities.q:ready(context)
    local cast = self:cast(context)
    if cast == nil then
      return false
    end

    local p1 = missile.new(self,
      {
        pos = context.champ.pos,
        dir = (cast.dir + vec2.random() / 5):normalize(),
        size = Q.SIZE,
        speed = Q.SPEED,
        range = Q.RANGE,
        colliders = context.enemies,
        color = { 1, 0.5, 1 }
      })
    local p2 = missile.new(self,
      {
        pos = context.champ.pos,
        dir = (cast.dir + vec2.random() / 5):normalize(),
        size = Q.SIZE,
        speed = Q.SPEED,
        range = Q.RANGE,
        colliders = context.enemies,
        color = { 1, 0.5, 1 }
      })
    context.spawn(p1)
    context.delay(0.05, function()
      context.spawn(p2)
    end)
    return true
  end

  function champ.abilities.q:hit(target)
    damage:new(Q.DAMAGE, damage.MAGIC):deal(champ, target)
    target:effect(require("effects.slow").new(Q.SLOW_DURATION, Q.SLOW_AMOUNT)) -- Add the slow.
  end

  -- Help, Pix! / Whimsy (combined W/E)
  function champ.abilities.we:ready(context)
    local cast = self:cast(context)
    if not cast then return false end

    --Apply effects
    cast.target:effect(require("effects.shield").new(WE.SHIELD_DURATION, WE.SHIELD_AMOUNT))
    cast.target:effect(require("effects.damage_buff").new(WE.DAMAGE_BUFF_DURATION, WE.DAMAGE_BUFF_AMOUNT))
    cast.target:effect(require("effects.slow").new(WE.SPEED_BUFF_DURATION, -WE.SPEED_BUFF_AMOUNT))
    return true
  end

  return champ
end

return lulu
