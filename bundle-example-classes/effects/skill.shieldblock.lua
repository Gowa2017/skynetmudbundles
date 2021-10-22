local Broadcast  = require("core.Broadcast")
local Heal       = require("core.Heal")
local EffectFlag = require("core.EffectFlag")
local Player     = require("core.Player")

return {
  config    = {
    name        = "Shield Block",
    description = "You are blocking incoming physical attacks!",
    type        = "skill:shieldblock",
  },
  flags     = { EffectFlag.BUFF },
  state     = { magnitude = 1, type      = "physical" },
  modifiers = {
    outgoingDamage = function(self, damage, current) return current end,
    incomingDamage = function(self, damage, currentAmount)
      if Heal:class_of(damage) or damage.attribute ~= "health" then
        return currentAmount
      end

      local absorbed = math.min(self.state.remaining, currentAmount);
      local partial  = self.state.remaining < currentAmount and " partially" or
                         "";
      self.state.remaining = self.state.remaining - absorbed;
      currentAmount = currentAmount - absorbed;

      Broadcast.sayAt(self.target,
                      string.format(
                        "You%q block the attack, preventing <bold>%q damage!",
                        partial, absorbed));
      if not self.state.remaining then self:remove() end
      return currentAmount;
    end,
  },
  listeners = {
    effectActivated   = function(self)
      self.state.remaining = self.state.magnitude;

      if Player:class_of(self.target) then
        self.target.addPrompt("shieldblock", function()
          local width     = 60 - #"Shield "
          local remaining = string.format("<bold>%q/%q", self.state.remaining,
                                          self.state.magnitude);
          return "<bold>Shield " ..
                   Broadcast.progress(width, (self.state.remaining /
                                        self.state.magnitude) * 100, "white") ..
                   " " .. remaining;
        end);
      end
    end,

    effectDeactivated = function(self)
      Broadcast.sayAt(self.target,
                      "You lower your shield, unable to block any more attacks.");
      if Player:class_of(self.target) then
        self.target:removePrompt("shieldblock");
      end
    end,
  },
};
