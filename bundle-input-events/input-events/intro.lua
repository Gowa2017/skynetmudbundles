local EventUtil = require "core.EventUtil"
local pretty    = require("pl.pretty")

return {
  event = function(state)
    return function(self, socket)
      local motd = "hello world"
      socket:write("gogogo")
      if motd then EventUtil.genSay(socket)(motd) end
      return socket:emit("login")
    end
  end,
}
