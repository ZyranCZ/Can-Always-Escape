# Always Escape

A mod for [gen1recomp](https://github.com/bryanthaboi/gen1recomp).

RUN always works against a wild Pokémon. No escape roll, no failed attempt, and
no free turn handed to the wild mon while you stand there.

## Install

Unzip the latest release into your game's `mods/` folder, press <kbd>F10</kbd>,
enable **Always Escape**. One option: on/off.

## What it does not touch

**Trainer battles** already refuse before any roll happens.

**Link battles** do reach the escape roll — `LinkBattle` sets `kind = "link"`,
which isn't `"trainer"`, so nothing stops it in vanilla. The mod only answers
for `kind == "wild"`, so you can't walk out on another player.

**Safari and the old man's demo** have their own paths and never reach the
hook. Excluded anyway, so a future change can't quietly route through here.

**Teleport, Roar, Whirlwind and the Poké Doll** end wild battles by other
routes entirely and keep their vanilla odds.

## About the Pokémon Tower Marowak

It needs no protection. Without the Silph Scope it's a ghost battle, which
escapes unconditionally in vanilla already. With the scope it's an ordinary
wild battle, and fleeing is a legal outcome the floor's script handles — you
step off the trigger, the flag stays unset, and 6F stays blocked until you
actually win. Escaping still won't get you past it; that's what the Poké Doll
is for, and this mod doesn't change that either.

Tests run headless: `lua tests/always_escape_test.lua`

MIT.
