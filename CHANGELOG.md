# Changelog

## [2.0.1] - 2026-08-14

### Changed

- Migrated and verified the mod against Gen1Recomp v0.1.86.
- Kept the implementation on the public, shared `battle.run` Mod API hook.
- Made live option refresh use the loader-provided `mod.id` instead of a
  duplicated identifier string.
- Added explicit Gen 1 and Gold loader-state coverage plus runtime regression
  coverage for legal, trainer, special, and trapping escape cases.
- Corrected the packaging ignore list so development tests are not distributed
  or mistaken for sandboxed mod source by strict validation.

## [2.0.0] - 2026-08-11

### Added

- Added verified Pokémon Gold support while preserving Red, Blue, and Yellow.
- Added the `ALWAYS ESCAPE` runtime option, defaulting to ON.
