local EventUtil = require "core.EventUtil"
local skynet    = require("skynet")

return {
  event = function(state)
    local motdfile = skynet.getenv("motd")
    local motd    
    if motdfile then
      local f = assert(io.open(motdfile, "r"),
                       string.format("motd file %s open error", motdfile))
      motd = f:read("a")
      f:close()
    end
    return function(self, socket)
      if motd then EventUtil.genSay(socket)(motd) end
      return socket:emit("login")
    end
  end,
}
