local Broadcast = require("core.Broadcast")

return {
  listeners = {
    playerEnter = function(state)
      return function(self, player)
        Broadcast.sayAt(player)
        Broadcast.sayAt(player,
                        "<cyan>Hint: You can pick up items from the room listed in '<white>look' with '<white>get' followed by a reasonable keyword for the item e.g., '<white>get cheese' Some items, like the chest, may contain items; you can check by looking at the item.",
                        80);
      end
    end,
  },
}
