local EventUtil         = require("core.EventUtil")
local wrapper           = require("core.lib.wrapper")
local pretty            = require("pl.pretty")

local passwordAttempts  = {};
local maxFailedAttempts = 2;

return {
  event = function(state)
    return function(self, socket, args)
      local write = EventUtil.genWrite(socket);

      local name  = args.account.username;

      if not passwordAttempts[name] then passwordAttempts[name] = 0; end

      -- Boot and log any failed password attempts
      if passwordAttempts[name] > maxFailedAttempts then
        write("Password attempts exceeded.\r\n");
        passwordAttempts[name] = 0;
        socket:stop()
        return false;
      end

      if not args.dontwelcome then
        write("Enter your password: ");
        socket:command("toggleEcho");
      end

      socket:once("data", function(pass)
        socket:command("toggleEcho");

        if not args.account:checkPassword(wrapper.trim(pass)) then
          write("<red>Incorrect password.\r\n");
          passwordAttempts[name] = passwordAttempts[name] + 1;

          return socket:emit("password", socket, args);
        end

        return socket:emit("choose-character", socket,
                           { account = args.account });
      end);
    end
  end,
};
