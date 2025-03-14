local damage = {}

damage.MAGIC = 0
damage.PHYSICAL = 1
damage.TRUE = 2

function damage:new(value, type)
  return setmetatable({
    value = value,
    type = type
  }, { __index = self })
end

function damage:deal(dealer, target)
  if target:has_effect("invulnerable") then
    return
  end
  local amount = self.value
  for _, buff in pairs(dealer:get_effects("damage_buff")) do
    amount = amount * buff.amount
  end
  for id, shield in pairs(target:get_effects("shield")) do
    local dmg_to_shield = math.min(amount, shield.amount)
    shield.amount = shield.amount - dmg_to_shield
    amount = amount - dmg_to_shield
    if shield.amount <= 0 then
      table.remove(target.effects, id)
    end
    if amount <= 0 then
      -- Fully absorbed
      return
    end
  end
  if self.type == damage.PHYSICAL then
    amount = amount / (1 + target.armor / 100)
  end
  if self.type == damage.MAGIC then
    amount = amount / (1 + target.mr / 100)
  end
  dealer.damage_dealt = dealer.damage_dealt + amount
  target.health = target.health - amount
end

return setmetatable(damage, damage)
