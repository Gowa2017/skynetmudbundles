local wrapper = require("core.lib.wrapper")
-- local Combat  = loadfile("bundles/bundle-example-combat/lib/Combat.lua")();
local Combat  = wrapper.loadBundleScript("lib/Combat")

--
-- Example real-time combat behavior for NPCs that goes along with the player's player-combat.js
-- Have combat implemented in a behavior like this allows two NPCs with this behavior to fight without
-- the player having to be involved
--
return function()
  return {
    listeners = {
      updateTick = function(state)
        ---@param  config table #Behavior config
        return function(self, config) Combat.updateRound(state, self); end
      end,

      ---
      killed     = function(state)
        ---
        ---NPC was killed
        ---@param config table # Behavior config
        ---@param killer Character killer
        return function(self, config, killer) end
      end,

      ---
      ---
      hit        = function(state)
        ---NPC hit another character
        ---@param config table #Behavior config
        ---@param damage Damage damage
        ---@param target Character target
        return function(self, config, damage, target) end
      end,

      damaged    = function(state)
        return function(self, config, damage)
          if self:getAttribute("health") <= 0 then
            Combat.handleDeath(state, self, damage.attacker);
          end
        end
      end,

      deathblow  = function(state)
        ---
        ---NPC killed a target
        ---@param  config any Behavior config
        ---@param target Character target
        ---
        return function(self, config, target)
          if not self:isInCombat() then
            Combat.startRegeneration(state, self);
          end
        end
      end,
    },
  };

end
