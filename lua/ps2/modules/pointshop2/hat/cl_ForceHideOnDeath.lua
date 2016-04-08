-- Fallback solution of PlayerDeath hook is killed by another addon
hook.Add("PS2_VisualsShouldShow", "ForceHideOnDeath", function( ply )
  if not ply:Alive() or ply:Team() == TEAM_SPECTATOR then
    return false
  end
end )
