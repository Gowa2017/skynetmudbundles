local Broadcast        = require("core.Broadcast")
local SkillType        = require("core.SkillType")
local Heal             = require("core.Heal")
local Damage           = require("core.Damage")
local sfmt             = string.format
local wrapper          = require("core.lib.wrapper")

local Combat           = wrapper.loadBundleScript("lib/Combat",
                                                  "bundle-example-combat");

-- config placed here just for easy copy/paste of self skill later on
local cooldown         = 4;
local damagePercent    = 150;
local favorAmount      = 3;
local reductionPercent = 30;

return {
  name            = "Judge",
  type            = SkillType.SKILL,
  requiresTarget  = true,
  initiatesCombat = true,
  cooldown        = cooldown,

  run             = function(state)
    return function(self, args, player, target)
      local effect       = state.EffectFactory:create("skill.judge", {}, {
        reductionPercent = reductionPercent,
      });
      effect.skill = self;
      effect.attacker = player;

      local amount       = Combat.calculateWeaponDamage(player) *
                             (damagePercent / 100);
      local damage       = Damage("health", amount, player, self,
                                  { type = "holy" });

      local favorRestore = Heal("favor", favorAmount, player, self);

      Broadcast.sayAt(player, sfmt(
                        "<bold><yellow>Concentrated holy energy slams into %s!",
                        target.name));
      Broadcast.sayAtExcept(player.room, sfmt(
                              "<bold><yellow>%s conjures concentrated holy energy and slams it into %s!",
                              player.name, target.name), { target, player });
      Broadcast.sayAt(target, sfmt(
                        "<bold><yellow>%s conjures concentrated holy energy and slams it into you!",
                        player.name));

      damage:commit(target);
      target:addEffect(effect);
      favorRestore:commit(player);
    end
  end,

  info            = function(self, player)
    return sfmt(
             "Slam your target with holy power, dealing <bold>%q% weapon damage and reducing damage of the target's next attack by <bold>%q%. Generates <bold><yellow>%q Favor.",
             damagePercent, reductionPercent, favorAmount);
  end,
};
