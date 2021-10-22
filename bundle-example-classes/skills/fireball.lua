local Broadcast     = require("core.Broadcast")
local Damage        = require("core.Damage")
local SkillType     = require("core.SkillType")

local sfmt          = string.format

local damagePercent = 100;
local manaCost      = 80;

local function getDamage(player)
  return player:getAttribute("intellect") * (damagePercent / 100);
end

---
---Basic mage spell
return {
  name            = "Fireball",
  type            = SkillType.SPELL,
  requiresTarget  = true,
  initiatesCombat = true,
  resource        = { attribute = "mana", cost      = manaCost },
  cooldown        = 10,

  run             = function(state)
    return function(self, args, player, target)
      local damage = Damage("health", getDamage(player), player, self,
                            { type = "physical" });

      Broadcast.sayAt(player,
                      "<bold>With a wave of your hand, you unleash a <red>fire<yellow>b<bold>all <bold>at your target!");
      Broadcast.sayAtExcept(player.room, sfmt(
                              "<bold>With a wave of their hand, %s unleashes a <red>fire<yellow>b<bold>all <bold>at %s!",
                              player.name, target.name), { player, target });
      if not target:isNpc() then
        Broadcast.sayAt(target, sfmt(
                          "<bold>With a wave of their hand, %s unleashes a <red>fire<yellow>b<bold>all <bold>at you!",
                          player.name));
      end
      damage:commit(target);
    end
  end,

  info            = function(info, player)
    return sfmt(
             "Hurl a magical fireball at your target dealing %q%% of your Intellect as Fire damage.",
             damagePercent);
  end,
};
