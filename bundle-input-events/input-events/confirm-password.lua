local wrapper   = require("core.lib.wrapper")

local EventUtil = require("core.EventUtil")
return {
  event = function(state)
    return function(self, socket, args)
      local say   = EventUtil.genSay(socket)
      local write = EventUtil.genWrite(socket)
      if not args.dontwelcome then
        write("<cyan>Confirm your password:");
        socket:command("toggleEcho");
      end

      socket:once("data", function(pass)
        socket:command("toggleEcho");

        if not args.account:checkPassword(wrapper.trim(pass)) then
          say("<red>Passwords do not match.");
          return socket:emit("change-password", socket, args);
        end

        say(""); -- echo was disabled, the user's Enter didn't make a newline
        return socket:emit(args.nextStage, socket, args);
      end)
    end
  end,
}
