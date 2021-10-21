local EventUtil = require("core.EventUtil")
local wrapper   = require("core.lib.wrapper")

return {
  event = function(state)
    return function(self, socket, args)
      local say   = EventUtil.genSay(socket)
      local write = EventUtil.genWrite(socket)
      say("You password must be at least 8 characters")
      write("<cyan>Enter you account password:")
      socket:command("toggleEcho")
      socket:once("data", function(pass)
        socket:command("toggleEcho")
        say("")
        pass = wrapper.trim(pass)
        if not pass then
          say("You must use a password")
          return socket:emit("change-password", socket, args)
        end

        if #pass < 8 then
          say("You password is not long enough.")
          return socket:emit("change-password", socket, args)
        end
        args.account:setPassword(pass)
        state.AccountManager:addAccount(args.account)
        args.account:save()
        socket:emit("confirm-password", socket, args)
      end)
    end
  end,
}
