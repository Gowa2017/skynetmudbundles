local Account   = require("core.Account")
local EventUtil = require("core.EventUtil")
local wrapper   = require("core.lib.wrapper")

return {
  event = function(state)
    return function(self, socket, name)
      local write      = EventUtil.genWrite(socket)
      local say        = EventUtil.genSay(socket)
      local newAccount
      write(string.format(
              "<bold>Do you want your account's username to be %q?<cyan>[y/n]",
              name))
      socket:once("data", function(data)
        data = wrapper.trim(data):lower()
        if data == "y" or data == "yes" then
          say("Creating account...")
          newAccount = Account({ username = name })
          return socket:emit("change-password", socket, {
            account   = newAccount,
            nextStage = "create-player",
          })
        elseif data and data == "n" or data == "no" then
          say("Let's try again!")
          return socket:emit("login", socket)
        end
        return socket:emit("create-account", socket, name)
      end)
    end
  end,
}
