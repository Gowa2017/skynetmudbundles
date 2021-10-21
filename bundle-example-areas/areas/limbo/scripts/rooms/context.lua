local sfmt      = string.format
local Broadcast = require("core.Broadcast")

return {
  listeners = {
    command = function(state)
      return function(self, player, commandName, args)
        Broadcast.sayAt(player,
                        sfmt(
                          "You just executed room context command '%q' with arguments %q",
                          commandName, args));
      end
    end,
  },
};
