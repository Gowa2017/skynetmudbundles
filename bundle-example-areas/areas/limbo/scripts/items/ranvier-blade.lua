local Broadcast = require("core.Broadcast")
local Heal      = require("core.Heal")
local sfmt      = string.format

return {
  listeners = {
    hit = function(state)
      return function(self, damage, target, finalAmount)
        if not damage.attacker or damage.attacker:isNpc() then return end

        -- Have to be careful in weapon scripts. If you have a weapon script that causes damage and
        -- it listens for the 'hit' event you will have to check to make sure that 'damage.source
        -- !== this' otherwise you could create an infinite loop the weapon's own damage triggering
        -- its script
        if math.random(100) < 50 then
          local amount = damage.metadata.critical and
                           damage.attacker:getMaxAttribute("health") or
                           math.floor(finalAmount / 4)
          local heal   = Heal("health", amount, damage.attacker, self)
          heal:commit(damage.attacker)
          Broadcast.sayAt(damage.attacker, sfmt(
                            "<white>The Blade of Ranvier shines with a bright white light and you see wisps of %qs soul flow into the blade.",
                            target.name), 80);

        end

      end
    end,
  },
};
