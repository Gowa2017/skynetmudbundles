local wrapper       = require("core.lib.wrapper")
local B             = require("core.Broadcast")
local CommandParser = wrapper.loadBundleScript("lib/CommandParser",
                                               "bundle-example-lib");
local ArgParser     = wrapper.loadBundleScript("lib/ArgParser",
                                               "bundle-example-lib");
local ItemUtil      = wrapper.loadBundleScript("lib/ItemUtil",
                                               "bundle-example-lib");
local stringx       = require("pl.stringx")
local tablex        = require("pl.tablex")
local sfmt          = string.format
local function handleDoor(player, doorRoom, targetRoom, door, action)
  if action == "open" then
    if door.locked then return B.sayAt(player, "The door is locked.") end
    if door.closed then
      B.sayAt(player, "The door swings open.")
      return doorRoom:openDoor(targetRoom)
    end
    return B.sayAt(player, "The door is not closed")
  elseif action == "close" then
    if door.locked or door.closed then
      return B.sayAt(player, "The door is already closed.");
    end

    B.sayAt(player, "The door swings closed.");
    return doorRoom:closeDoor(targetRoom);
  elseif action == "lock" then
    if door.locked then
      return B.sayAt(player, "The door is already locked.");
    end

    if not door.lockedBy then
      return B.sayAt(player, "You can't lock that door.");
    end

    local playerKey = player:hasItem(door.lockedBy);
    if not playerKey then return B.sayAt(player, "You don't have the key."); end

    doorRoom:lockDoor(targetRoom);
    return B.sayAt(player, "*Click* The door locks.");
  elseif action == "unlock" then
    if not door.locked then
      return B.sayAt(player, "It is already unlocked.");
    end

    if door.lockedBy then
      if player:hasItem(door.lockedBy) then
        B.sayAt(player, "*Click* The door unlocks.");
        return doorRoom:unlockDoor(targetRoom);
      end

      return B.sayAt(player, sfmt("The door can only be unlocked with %s.",
                                  keyItem.name));
    end

    return B.sayAt(player, "You can't unlock that door.");
  end
end

local function handleItem(player, item, action)
  if not item.closeable then
    return B.sayAt(player,
                   sfmt("%s is not a container.", ItemUtil.display(item)))
  end
  if action == "open" then
    if item.locked then
      return B.sayAt(player, sfmt("%s is locked.", ItemUtil.display(item)));
    end

    if item.closed then
      B.sayAt(player, sfmt("You open %s.", ItemUtil.display(item)));
      return item:open();
    end

    return B.sayAt(player,
                   sfmt("%s is already open, you can't open it any farther.",
                        ItemUtil.display(item)));
  elseif action == "close" then
    if item.locked or item.closed then
      return B.sayAt(player, "It's already closed.");
    end
    B.sayAt(player, sfmt("You close %s.", ItemUtil.display(item)));
    return item:close();
  elseif action == "lock" then
    if item.locked then return B.sayAt(player, "It's already locked."); end

    if not item.lockedBy then
      return B.sayAt(player, sfmt("You can't lock ${ItemUtil.display(item)}.",
                                  ItemUtil.display(item)));
    end

    local playerKey = player:hasItem(item.lockedBy);
    if player then
      B.sayAt(player, sfmt("*click* You lock %s.", ItemUtil.display(item)));

      return item:lock();
    end

    return B.sayAt(player, "The item is locked and you don't have the key.");
  elseif action == "unlock" then
    if not item.locked then
      return B.sayAt(player, sfmt("%s isn't locked...", ItemUtil.display(item)));
    end

    if item.closed then
      return B.sayAt(player, sfmt("%s isn't closed...", ItemUtil.display(item)));
    end

    if item.lockedBy then
      local playerKey = player:hasItem(item.lockedBy);
      if playerKey then
        B.sayAt(player,
                sfmt("*click* You unlock %s with %s.", ItemUtil.display(item),
                     ItemUtil.display(playerKey)));

        return item:unlock();
      end

      return B.sayAt(player, "The item is locked and you don't have the key.");
    end

    B.sayAt(player, sfmt("*Click* You unlock %s.", ItemUtil.display(item)));

    return item.unlock();
  end

end

return {
  aliases = { "close", "lock", "unlock" },
  usage   = "[open/close/lock/unlock] {item} / [open/close/lock/unlock] {door direction}/ [open/close/lock/unlock] {door direction}",
  command = function(state)
    return function(self, args, player, arg0)
      local action        = arg0:lower()
      if not args or #args < 1 then
        return B.sayAt(player, sfmt("What do you want to %s?", action));
      end

      if not player.room then
        return B.sayAt(player, "You are floating in the nether.");
      end

      local parts         = stringx.split(args, " ")
      local exitDirection = parts[1];
      if parts[1] == "door" and #parts > 2 then
        -- Exit is in second parameter
        exitDirection = parts[1];
      end

      local roomExit      = CommandParser:canGo(player, exitDirection);

      if roomExit then
        local roomExitRoom = state.RoomManager:getRoom(roomExit.roomId);
        local doorRoom     = player.room;
        local targetRoom   = roomExitRoom;
        local door         = doorRoom:getDoor(targetRoom);
        if not door then
          doorRoom = roomExitRoom;
          targetRoom = player.room;
          door = doorRoom:getDoor(targetRoom);
        end

        if door then
          return handleDoor(player, doorRoom, targetRoom, door, action);
        end
      end

      local item          = ArgParser.parseDot(args, tablex.keys(
                                                 player.inventory.items),
                                               tablex.keys(player.room.items));

      if item then return handleItem(player, item, action); end

      return B.sayAt(player, sfmt("You don't see %s here.", args));
    end
  end,
};
