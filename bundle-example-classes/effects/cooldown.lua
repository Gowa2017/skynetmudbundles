local Broadcast = require("core.Broadcast")
local sfmt      = string.format

---
---Dummy effect used to enforce skill cooldowns
return {
  config    = {
    name        = "Cooldown",
    description = "Cannot use ability while on cooldown.",
    unique      = false,
    type        = "cooldown",
  },
  state     = { cooldownId = nil },
  listeners = {
    effectDeactivated = function(self)
      Broadcast.sayAt(self.target,
                      sfmt("You may now use <bold>%s again.", self.skill.name));
    end,
  },
};
