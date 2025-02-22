local collision = {}
collision.__index = collision

function collision.c2c(c1, c2)
  return (c2.pos.x-c1.pos.x)^2 + (c2.pos.y-c1.pos.y)^2 <= ((c1.size+c2.size) / 2)^2
end

function collision.projectile(projectile)
  if not projectile.colliders then
    return false
  end
  if not projectile.pos then
    return false
  end
  local hit = false
  for _,col in pairs(projectile.colliders) do
    if projectile.hit_cols[col] ~= nil then
      goto continue
    end
    if collision.c2c(projectile, col) then
      projectile.hit_cols[col] = true
      projectile.ability:hit(col)
      hit = true
    end
      ::continue::
  end
  return hit
end

return collision
