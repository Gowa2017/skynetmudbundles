local Broadcast     = require("core.Broadcast")
local SkillType     = require("core.SkillType")
local Heal          = require("core.Heal")
local Damage        = require("core.Damage")
local sfmt          = string.format
local wrapper       = require("core.lib.wrapper")

local Combat        = wrapper.loadBundleScript("lib/Combat",
                                               "bundle-example-combat");

local damagePercent = 250;
local energyCost    = 20;

local function getDamage(player)
  return Combat.calculateWeaponDamage(player) * (damagePercent / 100);
end

--
-- Basic warrior attack
--
return {
  name            = "Lunge",
  type            = SkillType.SKILL,
  requiresTarget  = true,
  initiatesCombat = true,
  resource        = { attribute = "energy", cost      = energyCost },
  cooldown        = 6,

  run             = function(state)
    return function(self, args, player, target)
      local damage = Damage("health", getDamage(player), player, self,
                            { type = "physical" });

      Broadcast.sayAt(player,
                      "<red>You shift your feet and local loose a mighty attack!");
      Broadcast.sayAtExcept(player.room, sfmt(
                              "<red>%s lets loose a lunging attack on %s!",
                              player.name, target.name), { player, target });
      if not target:isNpc() then
        Broadcast.sayAt(target, sfmt(
                          "<red>$%s lunges at you with a fierce attack!",
                          player.name));
      end

      damage:commit(target);
    end
  end,

  info            = function(self, player)
    return sfmt(
             "Make a strong attack against your target dealing <bold>%q%% weapon damage.",
             damagePercent);
  end,
};
