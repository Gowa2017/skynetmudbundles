local Broadcast     = require("core.Broadcast")
local Damage        = require("core.Damage")
local sfmt          = string.format
local wrapper       = require("core.lib.wrapper")

local Combat        = wrapper.loadBundleScript("lib/Combat",
                                               "bundle-example-combat");

local cooldown      = 10;
local damagePercent = 350;
local favorAmount   = 5;

return {
  name            = "Smite",
  requiresTarget  = true,
  initiatesCombat = true,
  resource        = { attribute = "favor", cost      = favorAmount },
  cooldown        = cooldown,

  run             = function(state)
    return function(self, args, player, target)
      if not player.equipment["weild"] then
        return Broadcast.sayAt(player, "You don't have a weapon equipped.");
      end

      local amount = Combat.calculateWeaponDamage(player) *
                       (damagePercent / 100);

      local damage = Damage("health", amount, player, self, { type = "holy" });

      Broadcast.sayAt(player,
                      sfmt(
                        "<bold><yellow>Your weapon radiates holy energy and you strike %q!",
                        target.name));
      Broadcast.sayAtExcept(player.room,
                            sfmt(
                              "<bold><yellow>%q's weapon radiates holy energy and they strike %q!",
                              player.name, target.name), { target, player });
      Broadcast.sayAt(target,
                      sfmt(
                        "<bold><yellow>%q's weapon radiates holy energy and they strike you!",
                        player.name));
      damage:commit(target);
    end
  end,

  info            = function(self, player)
    return sfmt(
             "Empower your weapon with holy energy and strike, dealing <bold>%q% weapon damage. Requires a weapon.",
             damagePercent);
  end,
};
