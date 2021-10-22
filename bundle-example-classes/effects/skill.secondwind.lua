local Broadcast  = require("core.Broadcast")
local Heal       = require("core.Heal")
local EffectFlag = require("core.EffectFlag")

---
---Implementation effect for second wind skill
return {
  config    = { name = "Second Wind", type = "skill:secondwind" },
  flags     = { EffectFlag.BUFF },
  listeners = {
    damaged = function(self, damage)
      if damage.attribute ~= "energy" then return end

      if self.skill:onCooldown(self.target) then return end

      if (self.target:getAttribute("energy") /
        self.target:getMaxAttribute("energy") * 100 > self.state.threshold) then
        return;
      end

      Broadcast.sayAt(self.target, "<bold><yellow>You catch a second wind!");
      local amount = math.floor(self.target:getMaxAttribute("energy") *
                                  (self.state.restorePercent / 100));
      local heal   = Heal("energy", amount, self.target, self.skill);
      heal:commit(self.target);

      self.skill:cooldown(self.target);
    end,
  },
};
