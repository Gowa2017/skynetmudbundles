local Config  = require("core.Config")
local Player  = require("core.Player")
local Logger  = require("core.Logger")

local wrapper = require("core.lib.wrapper")

-- local PlayerClass = wrapper.loadBundleScript("lib/PlayerClass",
--                                              "bundle-example-classes");

return {
  event = function(state)
    local startingRoomRef = Config.get("startingRoom");
    if not startingRoomRef then
      Logger.error("No startingRoom defined in ranvier.json");
    end

    return function(self, socket, args)
      local player             = Player({
        name    = args.name,
        account = args.account,
      });

      -- TIP:DefaultAttributes: This is where you can change the default attributes for players
      local defaultAtttributes = {
        health    = 100,
        strength  = 20,
        agility   = 20,
        intellect = 20,
        stamina   = 20,
        armor     = 0,
        critical  = 0,
      };

      for attr, value in pairs(defaultAtttributes) do
        player:addAttribute(state.AttributeFactory:create(attr, value));
      end

      args.account:addCharacter(args.name);
      args.account:save();

      player:setMeta("class", args.playerClass);

      local room               = state.RoomManager:getRoom(startingRoomRef);
      player.room = room;
      state.PlayerManager:save(player);

      -- reload from manager so events are set
      player =
        state.PlayerManager:loadPlayer(state, player.account, player.name);
      player.socket = socket;

      socket:emit("done", socket, { player = player });
    end;
  end,
};
