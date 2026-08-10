-- Always Escape for Gen1Recomp
--
-- RUN always works against a wild Pokémon, instead of rolling the Gen 1
-- escape formula and losing a turn on failure.
--
-- WHAT IS ACTUALLY AT RISK
--
-- The battle.run hook is reached from exactly one place, BattleState:runRoll,
-- and that is called from two: the RUN menu choice (tryRun) and the NO
-- branch of the "Use next POKéMON?" prompt after a faint.  Both are escape
-- attempts, so guaranteeing the roll is the whole mod.
--
-- Trainer battles never get that far -- tryRun answers _NoRunningText and
-- returns before rolling -- so they are safe without any help.  Link
-- battles are NOT: LinkBattle sets kind = "link", which is not "trainer",
-- so the roll does happen there.  Guaranteeing it would let a player walk
-- out of a link battle at will, so the mod only ever answers for
-- kind == "wild".
--
-- Safari has its own escape path (safariAction "run") that never touches
-- runRoll, and the old man's catching demo drives its own menu, so neither
-- reaches this hook.  Both are excluded anyway, so a future change to
-- either cannot quietly start routing through here.
--
-- ABOUT THE POKEMON TOWER MAROWAK
--
-- Worth stating plainly, because it is the obvious thing to worry about:
-- it needs no protection, and the mod gives it none.
--
-- Without the Silph Scope the battle is a ghost battle, and runRollVanilla
-- opens with `if self.ghost then return true end` -- IsGhostBattle escapes
-- unconditionally in vanilla.  With the scope it is mechanically an
-- ordinary wild battle that "rolls for flight normally", so fleeing is
-- already a legal outcome, and POKEMON_TOWER_6F's onFinish handles it: any
-- result other than a win or a loss steps the player one tile right, off
-- the trigger, so the encounter does not immediately re-fire.  The flag
-- stays unset and the floor stays blocked until the fight is actually won.
--
-- In other words the only wild battles Gen 1 refuses to release you from
-- are the ones this mod cannot reach in the first place.

return function(mod)
  mod.options:define({
    { key = "enabled", label = "ALWAYS ESCAPE", type = "toggle", default = true },
  })

  local enabled

  local function readOptions()
    enabled = mod.options:get("enabled") and true or false
  end

  readOptions()
  mod.events:on("mod.options_changed", function(payload)
    if payload and payload.mod == "always_escape" then readOptions() end
  end)

  -- Whether this particular escape attempt is one the mod may answer for.
  -- Kept separate from the hook so a test can check the decision directly.
  local function guarantees(battle)
    if not enabled or not battle then return false end
    if battle.kind ~= "wild" then return false end
    if battle.safari or battle.demo then return false end
    return true
  end

  mod.hooks:wrap("battle.run", function(next, ctx)
    if guarantees(ctx and ctx.battle) then return true end
    return next()
  end)

  mod.exports.guarantees = guarantees
end
