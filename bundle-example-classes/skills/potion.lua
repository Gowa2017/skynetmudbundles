local Broadcast = require("core.Broadcast")
local Heal      = require("core.Heal")
local sfmt      = string.format
local SkillType = require("core.SkillType")

---
---Health potion item spell
return {
  name           = "Potion",
  type           = SkillType.SPELL,
  requiresTarget = true,
  targetSelf     = true,

  run            = function(state)
    return function(self, args, player)
      local stat   = self.options.stat or "health";
      local amount = math.floor(player:getMaxAttribute("health") *
                                  (self.options.restores / 100));
      local heal   = Heal(stat, amount, player, self);

      Broadcast.sayAt(player,
                      "<bold>You drink the potion and a warm feeling fills your body.");
      heal:commit(player);
    end
  end,

  info           = function(self, player)
    return sfmt("Restores <bold>%q% of your total %q.", self.options.restores,
                self.options.stat);
  end,
};
