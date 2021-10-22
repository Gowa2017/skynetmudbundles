local Broadcast   = require("core.Broadcast")
local wrapper     = require("core.lib.wrapper")

local PlayerClass = wrapper.loadBundleScript("lib/PlayerClass",
                                             "bundle-example-classes");

return {
  event = function(state)
    return function(self, socket, args)
      local player = args.player
      player:hydrate(state)
      player.playerClass = PlayerClass.get(player:getMeta("class"));
      player.playerClass:setupPlayer(state, player);
      player:save();

      player._lastCommandTime = os.time()
      state.CommandManager:get("look"):execute(nil, player)
      Broadcast.prompt(player)
      player.socket:emit("commands", player)
      player:emit("login")
    end
  end,
}
