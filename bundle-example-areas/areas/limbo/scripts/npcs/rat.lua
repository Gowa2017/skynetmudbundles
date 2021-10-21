local Broadcast = require("core.Broadcast")
local Logger    = require("core.Logger")
local tablex    = require("pl.tablex")
local sfmt      = string.format

return {
  listeners = {
    spawn      = function(state)
      return function(self)
        Broadcast.sayAt(self.room, "A rat scurries into view.");
        Logger.log("Spawned rat into Room [%q]", self.room.title);
      end
    end,

    ---
    --- Rat tries to use Rend every time it's available
    ---
    updateTick = function(state)
      return function(self)
        if not self:isInCombat() then return end
        local target = tablex.keys(self.combatants)[1]

        local rend   = state.SkillManager:get("rand")

        -- skills do both of these checks internally but I only want to send
        -- self message when execute would definitely succeed
        if not rend:onCooldown(self) and rend:hasEnoughResources(self) then
          Broadcast.sayAt(target,
                          "The rat bears its fangs and leaps at your throat!");
          rend:execute(nil, self, target);
        end
      end
    end,

    deathblow  = function(state)
      return function(self, player)
        Broadcast.sayAt(player.room,
                        sfmt(
                          "The rat seems to snicker evilly as %q drops dead from their wounds.",
                          player.name));
      end
    end,
  },
};
