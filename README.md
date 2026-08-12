# Always Escape

RUN never randomly fails when the game has already decided that a normal wild
escape attempt is allowed. The mod supports Pokémon Red, Blue, Yellow, and Gold.

## Try it

1. Copy the `always_escape` folder into the game's `mods/` directory.
2. Launch the game, press **F10**, enable **Always Escape**.

## Options

| Row | Values | Default |
| --- | --- | --- |
| `ALWAYS ESCAPE` | ON / OFF | ON |

## What it changes

In an ordinary wild battle, choosing **RUN** skips only the random escape-failure
roll. If RUN is otherwise legal, the escape succeeds immediately and no turn is
lost to a failed roll.

This does **not** mean that every battle can be escaped from. The mod leaves the
game's native rules for whether RUN is allowed intact.

- Trainer battles remain non-escapable.
- Gen 1 link battles are untouched.
- The Safari Zone and Old Man catching demo keep their own Gen 1 flows.
- Pokémon Tower Marowak keeps the same Gen 1 behavior as before.
- In Gold, special no-escape battles such as the Red Gyarados (`FORCESHINY`) and
  Rocket trap battles (`TRAP`) remain blocked.
- Mean Look / Spider Web and active Wrap trapping still prevent escape in Gold.
- Roamer enemy-flee behavior is not changed; the mod affects only the player's
  own legal RUN roll.

Turning `ALWAYS ESCAPE` **OFF** restores vanilla escape rolls.

## Tests

From the Gen1Recomp repository root:

```sh
ALWAYS_ESCAPE_MAIN=mods/always_escape/main.lua luajit mods/always_escape/tests/always_escape_test.lua
```

The package also includes `tests/always_escape_gold_integration_test.lua`, a
ROM-free Gold battle-engine integration test intended to run with the current
Gen1Recomp source tree:

```sh
luajit mods/always_escape/tests/always_escape_gold_integration_test.lua
```
