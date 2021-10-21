local Logger          = require("core.Logger")
local wrapper         = require("core.lib.wrapper")

local CommonFunctions = wrapper.loadBundleScript("lib/CommonFunctions");

return {
  event = function(state)
    return function(socket, args)
      if not args or not args.dontwelcome then
        socket:write("Welcome, what is your name?")
      end
      socket:once("data", function(name)
        name = wrapper.trim(name)
        local invalid     = CommonFunctions.validateName(name)
        if invalid then
          socket:write(invalid .. "\r\n")
          return socket:emit("login")
        end
        name = name:sub(1, 1):upper() .. name:sub(2)
        local ok, account = pcall(state.AccountManager.loadAccount,
                                  state.AccountManager, name)
        if not ok then
          Logger.error("No account found as %q.", name);
          Logger.error(err or "")
          socket:emit("create-account", socket, name)
          return
        end

        if account.banned then
          socket:write("This account has been banned.\r\n")
          socket:stop()
          return
        end
        if account.deleted then
          socket:write("This account has been deleted.\r\n")
          socket:stop()
          return
        end
        return socket:emit("password", socket,
                           { dontwelcome = false, account     = account })
      end)
    end
  end,
}
