local tablex       = require("pl.tablex")
local sfmt         = string.format
local wrapper      = require("core.lib.wrapper")

local Damage       = require("core.Damage")
local Logger       = require("core.Logger")
local CombatErrors = wrapper.loadBundleScript("lib/CombatErrors",
                                              "bundle-example-combat")
local Parser       = wrapper.loadBundleScript("lib/ArgParser",
                                              "bundle-example-lib")

---
--- This class is an example implementation of a Diku-style real time combat system. Combatants
--- attack and then have some amount of lag applied to them based on their weapon speed and repeat.
---
local M            = {}
function M.updateRound(state, attacker)
  if attacker.combatData.killed then
    -- entity was removed from the game but update event was still in flight, ignore it
    return false

  end
  if not attacker:isInCombat() then
    if not attacker:isNpc() then attacker:removePrompt("combat") end
    return false
  end
  local lastRoundStarted = attacker.combatData.roundStarted
  attacker.combatData.roundStarted = os.time()

  -- cancel if the attacker's combat lag hasn't expired yet
  if attacker.combatData.lag > 0 then
    local elapsed = os.time() - lastRoundStarted
    attacker.combatData.lag = attacker.combatData.lag - elapsed
    return false
  end

  -- currently just grabs the first combatant from their list but could easily be modified to
  -- implement a threat table and grab the attacker with the highest threat
  local target, err      = pcall(M.chooseCombatant, attacker)
  if not target then
    attacker:removeCombatant()
    attacker.combatData = {}
  end

  -- no targets left, remove attacker from combat
  if not target then
    attacker:removeFromCombat();
    -- reset combat data to remove any lag
    attacker.combatData = {};
    return false;
  end

  if target.combatData.killed then
    -- entity was removed from the game but update event was still in flight, ignore it
    return false;
  end

  M.makeAttack(attacker, target);
  return true;
end

---
---Find a target for a given attacker
---@param  attacker Character
---@return Character | nil
function M.chooseCombatant(attacker)
  if tablex.size(attacker.combatData) < 1 then return end
  for target, _ in ipairs(attacker.combatants) do
    if not target:hasAttribute("health") then
      error(CombatErrors.CombatInvalidTargetError)
    end
    if target:getAttribute("health") > 0 then return target end
  end

end

---
---Actually apply some damage from an attacker to a target
---@param attacker Character attacker
---@param target Character target
function M.makeAttack(attacker, target)
  local amount   = M.calculateWeaponDamage(attacker);
  local critical = false;

  if attacker:hasAttribute("critical") then
    local critChance = math.max(attacker.getMaxAttribute("critical") or 0, 0);
    critical = math.random(100) < critChance;
    if critical then amount = math.ceil(amount * 1.5) end
  end

  local weapon   = attacker.equipment["wield"];
  local damage   = Damage("health", amount, attacker, weapon or attacker,
                          { critical = critical });
  damage:commit(target);

  -- currently lag is really simple, the character's weapon speed = lag
  attacker.combatData.lag = M.getWeaponSpeed(attacker) * 1000;
end

---
---Any cleanup that has to be done if the character is killed
---@param deadEntity Character deadEntity
---@param killer? Character killer Optionally the character that killed the dead entity
function M.handleDeath(state, deadEntity, killer)
  if deadEntity.combatData.killed then return end

  deadEntity.combatData.killed = true;
  deadEntity:removeFromCombat();

  Logger.log("%q killed %q", killer and killer.name or "Something",
             deadEntity.name);

  if killer then
    deadEntity.combatData.killedBy = killer;
    killer:emit("deathblow", deadEntity);
  end
  deadEntity:emit("killed", killer);

  if deadEntity.isNpc() then state.MobManager:removeMob(deadEntity); end
end

function M.startRegeneration(state, entity)
  if entity:hasEffectType("regen") then return; end

  local regenEffect = state.EffectFactory:create("regen", { hidden = true },
                                                 { magnitude = 15 });
  if entity:addEffect(regenEffect) then regenEffect:activate(); end
end

function M.findCombatant(attacker, search)
  if #search < 1 then return end

  local possibleTargets = tablex.keys(attacker.room.npcs)
  if attacker:getMeta("pvp") then
    tablex.insertvalues(tablex.keys(attacker.room.players))
  end

  local target          = Parser.parseDot(search, possibleTargets);
  if not target then return end

  if target == attacker then error(CombatErrors.CombatSelfError) end

  if not target:hasBehavior("combat") then
    error(sfmt(CombatErrors.CombatPacifistError, target.name))
  end

  if not target:hasAttribute("health") then
    error(CombatErrors.CombatInvalidTargetError)
  end

  if not target.isNpc() and not target:getMeta("pvp") then
    error(sfmt(CombatErrors.CombatNonPvpError, target.name))
  end

  return target;
end

---
---Generate an amount of weapon damage
---@param attacker Character attacker
---@param average boolean average Whether to find the average or a random between min/max
---@return number
function M.calculateWeaponDamage(attacker, average)
  average = average == nil and false
  local weaponDamage = M.getWeaponDamage(attacker);
  local amount       = 0;
  if average then
    amount = (weaponDamage.min + weaponDamage.max) / 2
  else
    amount = math.random(weaponDamage.min, weaponDamage.max)
  end

  return M.normalizeWeaponDamage(attacker, amount);
end

---
---Get the damage of the weapon the character is wielding
---@param attacker Character attacker
---@return table #{max: number, min: number}
function M.getWeaponDamage(attacker)
  local weapon   = attacker.equipment["wield"];
  local min, max = 0, 0
  if weapon then
    min = weapon.metadata.minDamage
    max = weapon.metadata.maxDamage
  end
  return { max = max, min = min }

end

---
---Get the speed of the currently equipped weapon
---@param attacker Character attacker
---@return number
function M.getWeaponSpeed(attacker)
  local speed  = 2.0;
  local weapon = attacker.equipment["wield"];
  if not attacker.isNpc() and weapon then speed = weapon.metadata.speed end
  return speed;
end

---
---Get a damage amount adjusted by attack power/weapon speed
---@param attacker Character attacker
---@param amount number amount
---@return number
function M.normalizeWeaponDamage(attacker, amount)
  local speed = M.getWeaponSpeed(attacker);
  amount = amount + attacker:hasAttribute("strength") and
             attacker:getAttribute("strength") or attacker.level;
  return math.floor(amount / 3.5 * speed);
end
return M
