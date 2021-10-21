local Random        = math.random
local Broadcast     = require("core.Broadcast")

local wrapper       = require("core.lib.wrapper")

local CommandParser = wrapper.loadBundleScript("lib/CommandParser",
                                               "bundle-example-lib");
local say           = Broadcast.sayAt

return {
  usage   = "flee [direction]",
  command = function(state)
    return function(self, direction, player)
      if not player:isInCombat() then
        return say(player, "You jump at the sight of your own shadow.");
      end

      local roomExit  
      if direction then
        roomExit = CommandParser:canGo(player, direction);
      else
        local exits = player.room:getExits()
        roomExit = exits[Random(1, #exits)]
      end

      local randomRoom = state.RoomManager:getRoom(roomExit.roomId);

      if not randomRoom then
        say(player, "You can't find anywhere to run!");
        return;
      end

      local door       = player.room:getDoor(randomRoom) or
                           randomRoom:getDoor(player.room);
      if randomRoom and door and (door.locked or door.closed) then
        say(player, "In your panic you run into a closed door!");
        return;
      end

      say(player, "You cowardly flee from the battle!");
      player:removeFromCombat();
      player:emit("move", { roomExit = roomExit });
    end
  end,
};
