local EventUtil       = require("core.EventUtil")
local wrapper         = require("core.lib.wrapper")

local CommonFunctions = wrapper.loadBundleScript("lib/CommonFunctions",
                                                 "bundle-input-events");
return {
  event = function(state)
    return function(self, socket, args)
      local say   = EventUtil.genSay(socket)
      local write = EventUtil.genWrite(socket)
      write("<bold>What would you like to name your character? ");
      socket:once("data", function(name)
        say("");
        name = wrapper.trim(name)

        local invalid = CommonFunctions.validateName(name);

        if invalid then
          say(invalid);
          return socket:emit("create-player", socket, args);
        end

        name = name:sub(1, 1):upper() .. name:sub(2)

        local exists  = state.PlayerManager:exists(name);

        if exists then
          say("That name is already taken.");
          return socket:emit("create-player", socket, args);
        end

        args.name = name;
        return socket:emit("player-name-check", socket, args);
      end);
    end
  end,
}
