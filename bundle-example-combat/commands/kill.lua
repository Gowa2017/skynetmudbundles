local B       = require("core.Broadcast")
local Logger  = require("core.Logger")
local Combat  = loadfile("bundles/bundle-example-combat/lib/Combat.lua")()
local wrapper = require("core.lib.wrapper")

return {
  aliases = { "attack", "slay" },
  command = function(state)
    ---comment
    ---@param self any
    ---@param args any
    ---@param player Character
    ---@return any
    return function(self, args, player)
      args = wrapper.trim(args)
      if #args < 1 then return B.sayAt(player, "Kill whom?") end
      local ok, target = pcall(Combat.findCombatant, player, args)
      if not ok then
        Logger.error(res)
        return B.sayAt(player, res)
      end
      if not target then return B.sayAt(player, "They are not here.") end
      B.sayAt(player, string.format("You attack %q", target.name))
      player:initiateCombat(target)
      B.sayAtExcept(player.room,
                    string.format("%q attacks %q", player.name, target.name),
                    { player, target })
      if not target:isNpc() then
        B.sayAt(target, string.format("%q attacks you!", player.name))
      end

    end
  end,
}
