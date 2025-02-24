local movement = {
  PASSIVE = { tether = 2, dodge = 3, follow_team = 1.5, avoid_clumping = 2, random = 1.5, engage = 0, objective = 1.5, follow_cc = 0.5, follow_low_hp = 0.5, tank = 0, retreat = 1 },
  AGGRESSIVE = { tether = 1.5, dodge = 1, follow_team = 1, avoid_clumping = 1, random = 1, engage = 1, objective = 1, follow_cc = 2, follow_low_hp = 2, tank = 0, retreat = 1 },
  ENGAGE = { tether = 1, dodge = 1, follow_team = 1, avoid_clumping = 1, random = 1, engage = 10, objective = 1, follow_cc = 2, follow_low_hp = 2, tank = 1, retreat = 0.5 },
  PEEL = { tether = 1, dodge = 3, follow_team = 3, avoid_clumping = 2, random = 1.5, engage = 0.1, objective = 1, follow_cc = 0.5, follow_low_hp = 0.5, tank = 0.5, retreat = 1 },
  KITE = { tether = 1, dodge = 3, follow_team = 3, avoid_clumping = 2, random = 1.5, engage = 0, objective = 1.5, follow_cc = 0.8, follow_low_hp = 0.5, tank = 0, retreat = 1.5 },
}

return movement
