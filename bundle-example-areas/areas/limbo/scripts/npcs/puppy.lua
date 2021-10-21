local Broadcast = require("core.Broadcast")

return {
  listeners = {
    playerEnter = function(state)
      return function(self, player)
        if self.following then return end

        Broadcast.sayAt(player,
                        "The puppy lets out a happy bark and runs to your side.");
        self:follow(player);
      end
    end,
  },
};
