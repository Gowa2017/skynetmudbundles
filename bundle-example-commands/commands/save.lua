local Broadcast = require("core.Broadcast")

return {
  usage   = "save",
  command = function(state)
    return function(self, args, player)
      player:save(function() Broadcast.sayAt(player, "Saved."); end);
    end
  end,
};
