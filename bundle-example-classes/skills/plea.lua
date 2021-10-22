local Broadcast      = require("core.Broadcast")
local Heal           = require("core.Heal")
local sfmt           = string.format

local healPercent    = 20;
local favorCost      = 5;
local bonusThreshold = 30;
local cooldown       = 20;

---
---Basic cleric spell
---
return {
  name            = "Plea of Light",
  initiatesCombat = false,
  requiresTarget  = true,
  targetSelf      = true,
  resource        = { attribute = "favor", cost      = favorCost },
  cooldown        = cooldown,

  run             = function(state)
    return function(self, args, player, target)
      local maxHealth = target:getMaxAttribute("health");
      local amount    = math.floor(maxHealth * (healPercent / 100));
      if target:getAttribute("health") < (maxHealth * (bonusThreshold / 100)) then
        amount = amount * 2;
      end

      local heal      = Heal("health", amount, player, self);

      if target ~= player then
        Broadcast.sayAt(player, sfmt(
                          "<bold>You call upon to the light to heal %q's wounds.",
                          target.name));
        Broadcast.sayAtExcept(player.room,
                              sfmt(
                                "<bold>%q calls upon to the light to heal %q's wounds.",
                                player.name, target.name), { target, player });
        Broadcast.sayAt(target, sfmt(
                          "<bold>%q calls upon to the light to heal your wounds.",
                          player.name));
      else
        Broadcast.sayAt(player,
                        "<bold>You call upon to the light to heal your wounds.");
        Broadcast.sayAtExcept(player.room, sfmt(
                                "<bold>%q calls upon to the light to heal their wounds.",
                                player.name), { player, target });
      end

      heal:commit(target);
    end
  end,

  info            = function(self, player)
    return sfmt(
             "Call upon the light to heal <bold>%q%% of your or your target's max health. If below %q%% health, Plea of Light heals twice as much.",
             healPercent, bonusThreshold);
  end,
};
