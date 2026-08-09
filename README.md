# Always Escape

A mod for [gen1recomp](https://github.com/bryanthaboi/gen1recomp).

RUN always works against a wild Pokémon. No escape roll, no failed attempt, and
no free turn handed to the wild mon while you stand there.

**Check out my other mods:**<br>
* [Autofire A/B + Directional Keys Mod](https://github.com/ZyranCZ/autofire)<br>
* [Steel and/or Fairy and/or Typing Charts](https://github.com/ZyranCZ/Steel-and-or-Fairy-and-or-Typing-Charts)<br>
* [Move Category (PHYS/SPEC) Preview](https://github.com/ZyranCZ/Move-Category-Preview)<br>
* [Special Stat Split
](https://github.com/ZyranCZ/Special-Stat-Split/)<br>
* [Enemy HP Visible](https://github.com/ZyranCZ/Enemy-HP)
* [Can Always Escape](https://github.com/ZyranCZ/Can-Always-Escape)
* [Trainers Let You Choose Lead Pokemon](https://github.com/ZyranCZ/Trainers-Let-You-Choose-Lead-Pokemon)
* [Evolve in Battle](https://github.com/ZyranCZ/Evolve-in-Battle)
* [HELP Story Guide](https://github.com/ZyranCZ/HELP-Story-Guide/)



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
