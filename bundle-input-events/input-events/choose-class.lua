local Broadcast   = require("core.Broadcast")
local EventUtil   = require("core.EventUtil")
local wrapper     = require("core.lib.wrapper")
local tablex      = require("pl.tablex")

local PlayerClass = wrapper.loadBundleScript("lib/PlayerClass",
                                             "bundle-example-classes");

---
---Player class selection event
---
return {
  event = function(state)
    return function(self, socket, args)
      local say     = EventUtil.genSay(socket);
      local write   = EventUtil.genWrite(socket);

      ---Player selection menu:
      ---Can select existing player
      ---Can create new (if less than 3 living chars)
      say("  Pick your class");
      say(" --------------------------");
      local clses   = PlayerClass.getClasses();
      local classes = {}
      for id, instance in pairs(clses) do classes[id] = instance.config end
      for id, config in pairs(classes) do
        say(string.format("[<bold>%q] - <bold>%s", id, config.name));
        say(
          Broadcast.wrap(string.format("      %s\r\n", config.description), 80));
      end
      write("> ");

      socket:once("data", function(choice)
        choice = wrapper.trim(choice)

        local choiceres = {}
        for id, config in pairs(classes) do
          if id:find(choice) or config.name:lower():find(choice) then
            choiceres[#choiceres + 1] = id
          end
        end

        if not choice then
          return socket:emit("choose-class", socket, args);
        end
        args.playerClass = choiceres[1];
        socket:emit("finish-player", socket, args);
      end);
    end
  end,
};
