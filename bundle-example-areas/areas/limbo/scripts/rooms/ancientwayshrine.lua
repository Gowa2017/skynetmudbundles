local Broadcast = require("core.Broadcast")

return {
  listeners = {
    channelReceive = function(state)
      return function(self, channel, sender, message)
        if channel.name ~ -"say" then return end
        if not message:upper():match("mellon") then return end
        local downExit
        for exit, _ in ipairs(self:getExits()) do
          if exit.direction == "down" then
            downExit = exit
            break
          end
        end
        local downRoom = state.RoomManager:getRoom(downExit.roomId)
        Broadcast.sayAt(sender,
                        "You have spoken 'friend', you may enter. The trap door opens with a *click*");
        downRoom:unlockDoor(self);
        downRoom:openDoor(self);
      end
    end,
  },
}
