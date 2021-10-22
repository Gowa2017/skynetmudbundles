local Broadcast     = require("core.Broadcast")
local SkillType     = require("core.SkillType")
local sfmt          = string.format
local wrapper       = require("core.lib.wrapper")

local Combat        = wrapper.loadBundleScript("lib/Combat",
                                               "bundle-example-combat");

-- config placed here just for easy copy/paste of self skill later on
local cooldown      = 10;
local cost          = 50;
local duration      = 20 * 1000;
local tickInterval  = 3;
local damagePercent = 400;

local function totalDamage(player)
  return Combat.calculateWeaponDamage(player) * (damagePercent / 100)
end
---
---DoT (Damage over time) skill
---
return {
  name            = "Rend",
  type            = SkillType.SKILL,
  requiresTarget  = true,
  initiatesCombat = true,
  resource        = { attribute = "energy", cost      = cost },
  cooldown        = cooldown,

  run             = function(state)
    return function(self, args, player, target)
      local effect = state.EffectFactory:create("skill.rend", {
        duration     = duration,
        description  = self:info(player),
        tickInterval = tickInterval,
      }, { totalDamage = totalDamage(player) });
      effect.skill = self;
      effect.attacker = player;

      effect:on("effectDeactivated", function()
        Broadcast.sayAt(player,
                        sfmt("<red><bold>%q stops bleeding.", target.name));
      end);

      Broadcast.sayAt(player,
                      sfmt(
                        "<red>With a vicious attack you open a deep wound in <bold>%q!",
                        target.name));
      Broadcast.sayAtExcept(player.room, sfmt("<red>%q viciously rends %q.",
                                              player.name, target.name),
                            { target, player });
      Broadcast.sayAt(target, sfmt("<red>%s viciously rends you!", player.name));
      target:addEffect(effect);
    end
  end,

  info            = function(self, player)
    return sfmt(
             "Tear a deep wound in your target's flesh dealing <bold>%q% weapon damage over <bold>%q seconds.",
             damagePercent, duration / 1);
  end,
};
