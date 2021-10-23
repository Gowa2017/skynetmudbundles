local Broadcast = require("core.Broadcast")

return {
  usage   = "quit",
  command = function(state)
    return function(self, args, player)
      if player:isInCombat() then
        return
          Broadcast.sayAt(player, "You're too busy fighting for your life!");
      end

      player:save(function()
        Broadcast.sayAt(player, "Goodbye!");
        Broadcast.sayAtExcept(player.room,
                              string.format("%s disappears.", player.name),
                              player);
        state.PlayerManager:removePlayer(player, true);
      end);
    end
  end,
};
