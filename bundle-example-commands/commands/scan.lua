local B      = require("core.Broadcast")
local sfmt   = string.format
local tablex = require("pl.tablex")

--
-- See brief details of npcs/players in nearby rooms
return {
  usage   = "scan",
  command = function(state)
    return function(self, args, player)
      for _, exit in ipairs(player.room.exits) do
        local room = state.RoomManager:getRoom(exit.roomId);

        B.at(player, sfmt("(%s) %s", exit.direction, room.title));

        if tablex.size(room.npcs) > 0 or tablex.size(room.players) > 0 then
          B.sayAt(player, ":");
        else
          B.sayAt(player);
        end

        for npc, _ in pairs(room.npcs) do
          B.sayAt(player, sfmt("  [NPC] %s", npc.name));
        end
        for pc, _ in pairs(room.players) do
          B.sayAt(player, sfmt("  [NPC] %s", pc.name));
        end
        B.sayAt(player);
      end
    end
  end,
};
