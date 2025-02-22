local movement = {
  PASSIVE = { tether = 2, dodge = 3, follow_team = 1.5, avoid_clumping = 2, random = 1.5, engage = 0, objective = 1.5 },
  AGGRESSIVE = { tether = 1, dodge = 1, follow_team = 1, avoid_clumping = 1, random = 1, engage = 1, objective = 1 },
  ENGAGE = { tether = 1, dodge = 1, follow_team = 1, avoid_clumping = 1, random = 1, engage = 10, objective = 1 },
  PEEL = { tether = 1, dodge = 3, follow_team = 3, avoid_clumping = 2, random = 1.5, engage = 0.1, objective = 1 }
}

return movement
