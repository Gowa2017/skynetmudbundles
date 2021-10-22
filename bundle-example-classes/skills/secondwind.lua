local SkillFlag      = require("core.SkillFlag")
local SkillType      = require("core.SkillType")
local sfmt           = string.format

local interval       = 2 * 60;
local threshold      = 30;
local restorePercent = 50;

--
-- Basic warrior passive
return {
  name            = "Second Wind",
  type            = SkillType.SKILL,
  flags           = { SkillFlag.PASSIVE },
  effect          = "skill.secondwind",
  cooldown        = interval,

  configureEffect = function(effect)
    effect.state[threshold] = threshold
    effect.state[restorePercent] = restorePercent
    return effect;
  end,

  info            = function(self, player)
    return sfmt(
             "Once every %q minutes, when dropping below %q energy, restore %q%% of your max energy.",
             interval / 60, threshold, restorePercent);
  end,
};
