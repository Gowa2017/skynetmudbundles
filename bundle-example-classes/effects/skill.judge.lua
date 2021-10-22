local Broadcast  = require("core.Broadcast")
local EffectFlag = require("core.EffectFlag")
local Heal       = require("core.Heal")

--
-- Effect applied by Judge skill. Reduces damage done.
return {
  config    = {
    name        = "Judged",
    description = "Damage of your next attack is reduced.",
    type        = "skill:judge",
  },
  flags     = { EffectFlag.DEBUFF },
  state     = { reductionPercent = 0 },
  modifiers = {
    incomingDamage = function(self, damage, current) return current end,
    outgoingDamage = function(self, damage, currentAmount)
      if Heal:class_of(damage) or damage.attribute ~= "health" then
        return currentAmount

      end
      local reduction = math.floor(currentAmount *
                                     (self.state.reductionPercent / 100));
      return currentAmount - reduction;
    end,
  },
  listeners = {
    effectActivated   = function(self)
      Broadcast.sayAt(self.target, "<yellow>The holy judgement weakens you.");
    end,

    effectDeactivated = function(self)
      Broadcast.sayAt(self.target, "<yellow>You feel your strength return.");
    end,

    hit               = function(self) self:remove(); end,
  },
};
