local Broadcast  = require("core.Broadcast")
local EffectFlag = require("core.EffectFlag")

return {
  config    = {
    name      = "Potion Buff",
    type      = "potion.buff",
    refreshes = true,
  },
  flags     = { EffectFlag.BUFF },
  state     = { stat      = "strength", magnitude = 1 },
  modifiers = {
    attributes = function(self, attribute, current)
      if attribute ~= self.state.stat then return current end

      return current + self.state.magnitude;
    end,
  },
  listeners = {
    effectRefreshed   = function(self, newEffect)
      self.startedAt = os.time()
      Broadcast.sayAt(self.target, "You refresh the potion's magic.");
    end,

    effectActivated   = function(self)
      Broadcast.sayAt(self.target,
                      "You drink down the potion and feel more powerful!");
    end,

    effectDeactivated = function(self)
      Broadcast.sayAt(self.target, "You feel less powerful.");
    end,
  },
};
