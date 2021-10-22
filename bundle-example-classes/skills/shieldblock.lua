local Broadcast     = require("core.Broadcast")
local SkillType     = require("core.SkillType")
local sfmt          = string.format

-- config placed here just for easy configuration of self skill later on
local cooldown      = 45;
local cost          = 50;
local healthPercent = 15;
local duration      = 20 * 1000;

---
---Damage mitigation skill
---
return {
  name           = "Shield Block",
  type           = SkillType.SKILL,
  requiresTarget = false,
  resource       = { attribute = "energy", cost      = cost },
  cooldown       = cooldown,

  run            = function(state)
    return function(self, args, player, target)
      if not player.equipment["shield"] then
        Broadcast.sayAt(player, "You aren't wearing a shield!");
        return false;
      end

      local effect = state.EffectFactory:create("skill.shieldblock", {
        duration    = duration,
        description = self:info(player),
      }, {
        magnitude = math.floor(
          player:getMaxAttribute("health") * (healthPercent / 100)),
      });
      effect.skill = self;

      Broadcast.sayAt(player,
                      "<bold>You raise your shield, bracing for incoming attacks!");
      Broadcast.sayAtExcept(player.room, sfmt(
                              "<bold>%q raises their shield, bracing for incoming damage.",
                              player.name), { player });
      player:addEffect(effect);
    end
  end,

  info           = function(self, player)
    return sfmt(
             "Raise your shield block damage up to <bold>%q%% of your maximum health for <bold>%q seconds. Requires a shield.",
             healthPercent, duration / 1);
  end,
};
