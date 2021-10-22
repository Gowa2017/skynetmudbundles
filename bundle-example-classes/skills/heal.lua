local B           = require("core.Broadcast")
local SkillType   = require("core.SkillType")
local Heal        = require("core.Heal")
local sfmt        = string.format

local healPercent = 300;
local energyCost  = 40;

local function getHeal(player)
  return player:getAttribute("intellect") * (healPercent / 100);
end

---
---Basic cleric spell
return {
  name            = "Heal",
  type            = SkillType.SPELL,
  requiresTarget  = true,
  initiatesCombat = false,
  targetSelf      = true,
  resource        = { attribute = "energy", cost      = energyCost },
  cooldown        = 10,

  run             = function(state)
    return function(self, args, player, target)
      local heal = Heal("health", getHeal(player), player, self);

      if target ~= player then
        B.sayAt(player, sfmt(
                  "<bold>You call upon to the light to heal %s's wounds.",
                  target.name));
        B.sayAtExcept(player.room,
                      sfmt(
                        "<bold>%s calls upon to the light to heal %s's wounds.",
                        player.name, target.name), { target, player });
        B.sayAt(target, sfmt(
                  "<bold>%s calls upon to the light to heal your wounds.",
                  player.name));
      else
        B.sayAt(player, "<bold>You call upon to the light to heal your wounds.");
        B.sayAtExcept(player.room, sfmt(
                        "<bold>%s calls upon to the light to heal their wounds.",
                        player.name), { player, target });
      end

      heal:commit(target);
    end
  end,

  info            = function(info, player)
    return sfmt(
             "Call upon the light to heal your target's wounds for %q%% of your Intellect.",
             healPercent);
  end,
};
