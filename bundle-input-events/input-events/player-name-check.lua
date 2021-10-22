local EventUtil = require("core.EventUtil")
local wrapper   = require("core.lib.wrapper")

return {
  event = function(state)
    return function(self, socket, args)
      local say   = EventUtil.genSay(socket);
      local write = EventUtil.genWrite(socket);

      write(string.format(
              "<bold>%q doesn't exist, would you like to create it? <cyan>[y/n] ",
              args.name));
      socket:once("data", function(confirmation)
        say("");
        confirmation = wrapper.trim(confirmation):lower()

        if not confirmation:find("[yn]") then
          return socket:emit("player-name-check", socket, args);
        end

        if confirmation == "n" then
          say("Let's try again...");
          return socket:emit("create-player", socket, args);
        end
        socket:emit("choose-class", socket, args);
      end);
    end
  end,
};
