-- Drives the run hook through the engine's own Hooks chain.
-- Run from the game root:  lua tests/always_escape_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path

local modPath = os.getenv("ALWAYS_ESCAPE_MAIN") or "mods/always_escape/main.lua"

local Hooks = require("src.mods.Hooks")

local hooks = Hooks.new()
local options = { enabled = true }
local listeners = {}

local mod = {
  options = { define = function() end, get = function(_, k) return options[k] end },
  events = { on = function(_, name, fn)
    listeners[name] = listeners[name] or {}
    table.insert(listeners[name], fn)
  end },
  hooks = { wrap = function(_, name, cb)
    return hooks:wrap(name, cb, 0, "always_escape")
  end },
  exports = {},
  log = { info = function() end, warn = function() end },
}

assert(loadfile(modPath), "cannot load " .. modPath)()(mod)

local function setOption(key, value)
  options[key] = value
  for _, fn in ipairs(listeners["mod.options_changed"] or {}) do
    fn({ mod = "always_escape", key = key, value = value })
  end
end

-- Stands in for BattleState:runRoll: the vanilla roll it would have made,
-- forced to fail so a true result can only have come from the mod.
local vanillaCalls
local function attempt(battle)
  vanillaCalls = 0
  return hooks:call("battle.run", function()
    vanillaCalls = vanillaCalls + 1
    return false
  end, { battle = battle, pSpd = 10, eSpd = 200, attempts = 1 })
end

local function battle(fields)
  local b = { kind = "wild" }
  for k, v in pairs(fields or {}) do b[k] = v end
  return b
end

local failures = 0
local function check(label, got, want)
  local ok = got == want
  if not ok then failures = failures + 1 end
  print(("%-58s %s  (got %s, want %s)")
    :format(label, ok and "PASS" or "FAIL", tostring(got), tostring(want)))
end

-- the point of the mod: a wild escape that vanilla would have failed
check("a hopeless wild escape succeeds", attempt(battle()), true)
check("and the vanilla roll is not consulted", vanillaCalls, 0)

-- Link battles reach runRoll too -- LinkBattle sets kind = "link", which is
-- not "trainer", so tryRun does not short-circuit.  Walking out of one at
-- will is not on offer.
check("a link battle still rolls", attempt(battle{ kind = "link" }), false)
check("and it used the vanilla roll", vanillaCalls, 1)

-- trainers never get this far in the engine, but if that ever changed the
-- mod must not be the thing that lets you flee one
check("a trainer battle still rolls", attempt(battle{ kind = "trainer" }), false)

-- neither of these routes through runRoll today; excluded so that a future
-- change cannot quietly start doing so
check("the safari zone is left alone", attempt(battle{ safari = true }), false)
check("the old man demo is left alone", attempt(battle{ demo = true }), false)

-- The Pokémon Tower ghost escapes unconditionally in vanilla already
-- (runRollVanilla opens with `if self.ghost then return true end`), so the
-- mod changes nothing there; with the Silph Scope it is an ordinary wild
-- battle and fleeing is a legal outcome the floor's script handles.
check("the disguised ghost is a wild battle and escapes",
      attempt(battle{ ghost = true }), true)
check("the unveiled marowak escapes like any wild mon",
      attempt(battle{ noCatch = true }), true)

-- guards
check("no battle in the context", attempt(nil), false)

setOption("enabled", false)
check("disabled mod defers to vanilla", attempt(battle()), false)
check("and the vanilla roll ran", vanillaCalls, 1)
setOption("enabled", true)
check("re-enabling restores the guarantee", attempt(battle()), true)

-- the decision itself, without the chain
check("guarantees() agrees for wild", mod.exports.guarantees(battle()), true)
check("guarantees() refuses link",
      mod.exports.guarantees(battle{ kind = "link" }), false)

print(failures == 0 and "\nall checks passed"
                    or ("\n" .. failures .. " check(s) failed"))
os.exit(failures == 0 and 0 or 1)
