-- ROM-free integration test against the real Gen 2 Battle:tryRun path.
-- Run from the Gen1Recomp repository root after placing this mod at
-- mods/always_escape:
--   luajit mods/always_escape/tests/always_escape_gold_integration_test.lua
--
-- This deliberately tests the engine's PRE-ROLL no-escape gates, not only the
-- mod's exported classifier.  A passing test proves that the shared battle.run
-- hook cannot bypass trainer, FORCESHINY/TRAP, Mean Look/Spider Web, or Wrap.
package.path = "./?.lua;./?/init.lua;" .. package.path

local Hooks = require("src.mods.Hooks")
local Runtime = require("src.mods.Runtime")
local Battle = require("src.battle.gen2.Battle")

local hooks = Hooks.new()
local events = { emit = function() end, removeOwner = function() end }
Runtime.install(events, hooks, {})

local options = { enabled = true }
local listeners = {}
local mod = {
  options = {
    define = function() end,
    get = function(_, key) return options[key] end,
  },
  events = {
    on = function(_, name, fn)
      listeners[name] = listeners[name] or {}
      table.insert(listeners[name], fn)
    end,
  },
  hooks = {
    wrap = function(_, name, cb)
      return hooks:wrap(name, cb, 0, "always_escape")
    end,
  },
  exports = {},
  log = { info = function() end, warn = function() end },
}

local modPath = os.getenv("ALWAYS_ESCAPE_MAIN") or "mods/always_escape/main.lua"
assert(loadfile(modPath), "cannot load " .. modPath)()(mod)

local function setEnabled(value)
  options.enabled = value
  for _, fn in ipairs(listeners["mod.options_changed"] or {}) do
    fn({ mod = "always_escape", key = "enabled", value = value })
  end
end

local hookDownstreamCalls = 0
hooks:wrap("battle.run", function(next)
  hookDownstreamCalls = hookDownstreamCalls + 1
  return next()
end, -100, "always_escape_test_probe")

local function mon(name, speed)
  return {
    species = name,
    name = name,
    level = 20,
    hp = 50,
    maxHp = 50,
    stats = {
      hp = 50,
      attack = 30,
      defense = 30,
      speed = speed,
      specialAttack = 30,
      specialDefense = 30,
    },
    moves = {},
  }
end

local DATA = { items = {}, moves = {}, pokemon = {}, type_chart = {} }
local function failRoll(n) return math.max(0, (n or 1) - 1) end

local function wild(opts)
  opts = opts or {}
  local b = Battle.new({
    data = DATA,
    party = { mon("SLOWMON", 10) },
    wild = mon("FASTMON", 200),
    battleType = opts.battleType,
    random = failRoll,
  })
  return b
end

local failures = 0
local function check(label, got, want)
  local ok = got == want
  if not ok then failures = failures + 1 end
  print(("%-68s %s  (got %s, want %s)")
    :format(label, ok and "PASS" or "FAIL", tostring(got), tostring(want)))
end

-- The Gold object shape itself is recognized by the mod.
do
  local b = wild()
  check("Gold Battle.new object is eligible", mod.exports.guarantees(b), true)
end

-- Deterministic vanilla failure: speed 10 vs 200 and random=255.  With the
-- mod enabled, tryRun must still succeed and the lower hook/vanilla must never
-- be consulted.
do
  local b = wild()
  hookDownstreamCalls = 0
  check("Gold ordinary wild RUN is guaranteed", b:tryRun(), true)
  check("Gold successful RUN ends with outcome=run", b.outcome, "run")
  check("guaranteed Gold RUN short-circuits downstream roll", hookDownstreamCalls, 0)
end

-- OFF must restore the exact deterministic vanilla failure.
do
  setEnabled(false)
  local b = wild()
  hookDownstreamCalls = 0
  check("Gold option OFF restores vanilla failed roll", b:tryRun(), false)
  check("Gold option OFF reaches downstream/vanilla", hookDownstreamCalls, 1)
  check("failed vanilla roll does not end the battle", b.over, false)
  setEnabled(true)
end

-- Trainer gate must refuse BEFORE battle.run.
do
  local b = Battle.new({
    data = DATA,
    party = { mon("SLOWMON", 10) },
    trainer = { class = "TEST", name = "TESTER", party = { mon("FASTMON", 200) } },
    random = failRoll,
  })
  hookDownstreamCalls = 0
  check("Gold trainer RUN remains blocked", b:tryRun(), false)
  check("trainer refusal never reaches battle.run", hookDownstreamCalls, 0)
end

-- Special story battle-type gates must refuse before the hook.
for _, case in ipairs({
  { "FORCESHINY", Battle.BATTLETYPE_FORCESHINY },
  { "TRAP", Battle.BATTLETYPE_TRAP },
}) do
  local b = wild({ battleType = case[2] })
  hookDownstreamCalls = 0
  check("Gold " .. case[1] .. " RUN remains blocked", b:tryRun(), false)
  check(case[1] .. " refusal never reaches battle.run", hookDownstreamCalls, 0)
end

-- Mean Look / Spider Web state lives on the enemy volatile and pins the player.
do
  local b = wild()
  b:volatile(b.enemy).trapsTarget = true
  hookDownstreamCalls = 0
  check("Gold CANT_RUN trap remains blocked", b:tryRun(), false)
  check("CANT_RUN refusal never reaches battle.run", hookDownstreamCalls, 0)
end

-- Active Wrap on the player's mon likewise pins RUN before the roll.
do
  local b = wild()
  b:volatile(b.player).wrapCount = 3
  hookDownstreamCalls = 0
  check("Gold Wrap trap remains blocked", b:tryRun(), false)
  check("Wrap refusal never reaches battle.run", hookDownstreamCalls, 0)
end

print(failures == 0 and "\nall Gold integration checks passed"
                    or ("\n" .. failures .. " Gold integration check(s) failed"))
os.exit(failures == 0 and 0 or 1)
