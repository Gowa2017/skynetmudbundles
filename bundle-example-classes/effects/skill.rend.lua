local Broadcast  = require("core.Broadcast")
local EffectFlag = require("core.EffectFlag")
local Damage     = require("core.Damage")
---
---Implementation effect for a Rend damage over time skill
return {
  config    = { name      = "Rend", type      = "skill:rend", maxStacks = 3 },
  flags     = { EffectFlag.DEBUFF },
  listeners = {
    effectStackAdded  = function(self, newEffect)
      -- add incoming rend's damage to the existing damage but don't extend duration
      self.state.totalDamage = self.state.totalDamage +
                                 newEffect.state.totalDamage;
    end,

    effectActivated   = function(self)
      Broadcast.sayAt(self.target,
                      "<bold><red>You've suffered a deep wound, it's bleeding profusely");
    end,

    effectDeactivated = function(self)
      Broadcast.sayAt(self.target, "Your wound has stopped bleeding.");
    end,

    updateTick        = function(self)
      local amount = math.floor(self.state.totalDamage /
                                  math.floor(
                                    (self.config.duration / 1000) /
                                      self.config.tickInterval));

      local damage = Damage("health", amount, self.attacker, self);
      damage:commit(self.target);
    end,

    killed            = function(self) self:remove(); end,
  },
};
