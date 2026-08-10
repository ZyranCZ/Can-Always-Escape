# Always Escape

RUN always works against a wild Pokémon, instead of rolling the Gen 1 escape
formula and losing a turn on failure.

## Try it

1. Copy the `always_escape` folder into the game's `mods/` directory.
2. Launch the game, press **F10**, enable **Always Escape**.

## Options

| Row | Values | Default |
| --- | --- | --- |
| `ALWAYS ESCAPE` | ON / OFF | ON |

## What it covers

The `battle.run` hook is reached from one place, `BattleState:runRoll`, which
is called from two: the RUN menu choice and the NO branch of the "Use next
POKéMON?" prompt after a faint. Both are escape attempts, so guaranteeing the
roll is the whole mod.

## What it deliberately does not cover

**Trainer battles** never get that far — `tryRun` answers `_NoRunningText` and
returns before rolling.

**Link battles** do reach it. `LinkBattle` sets `kind = "link"`, which is not
`"trainer"`, so the roll happens there in vanilla. Guaranteeing it would let a
player walk out of a link battle at will, so the mod only ever answers for
`kind == "wild"`.

**The Safari Zone** has its own escape path that never touches `runRoll`, and
**the old man's catching demo** drives its own menu. Neither reaches this hook
today; both are excluded anyway, so a future change to either cannot quietly
start routing through here.

## About the Pokémon Tower Marowak

The obvious thing to worry about, and it needs no protection.

Without the Silph Scope it is a ghost battle, and `runRollVanilla` opens with
`if self.ghost then return true end` — `IsGhostBattle` escapes unconditionally
in vanilla, so the mod changes nothing. With the scope it is mechanically an
ordinary wild battle that rolls for flight normally, so fleeing is already a
legal outcome, and `POKEMON_TOWER_6F`'s `onFinish` handles it: any result other
than a win or a loss steps the player one tile right, off the trigger, so the
encounter does not immediately re-fire. The flag stays unset and the floor
stays blocked until the fight is actually won.

The only wild battles Gen 1 refuses to release you from are the ones this mod
cannot reach in the first place.

## Tests

```
lua tests/always_escape_test.lua
```
