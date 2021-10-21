local AreaAudience    = require("core.AreaAudience")
local PartyAudience   = require("core.PartyAudience")
local PrivateAudience = require("core.PrivateAudience")
local RoomAudience    = require("core.RoomAudience")
local WorldAudience   = require("core.WorldAudience")

local Channel         = require("core.Channel")
local sfmt            = string.format

local titles          = {
  chat  = "世界",
  say   = "房间",
  tell  = "私聊",
  yell  = "区域",
  gtell = "组队",
};
return {
  Channel({
    name        = "chat",
    aliales     = { "." },
    color       = { "bold", "green" },
    description = "Chat with everyone on the game",
    audience    = WorldAudience(),
    formatter   = {
      sender = function(sender, target, message, colorify)
        return
          colorify(sfmt("[%s]%s: %s", titles["chat"], sender.name, message));
      end,

      target = function(sender, target, message, colorify)
        return
          colorify(sfmt("[%s]%s: %s", titles["chat"], sender.name, message));
      end,
    },
  }),
  Channel({
    name        = "say",
    color       = { "yellow" },
    description = "Send a message to all players in your room",
    audience    = RoomAudience(),
    formatter   = {
      sender = function(sender, target, message, colorify)
        return colorify(sfmt("[%s]%s: %s", sender.name, message));
      end,

      target = function(sender, target, message, colorify)
        return colorify(sfmt("%s: %s", sender.name, message))
      end,
    },
  }),
  Channel({
    name        = "tell",
    color       = { "bold", "cyan" },
    description = "Send a private message to another player",
    audience    = PrivateAudience(),
    formatter   = {
      sender = function(sender, target, message, colorify)
        return
          colorify(sfmt("[%s]%s: %s", titles["tell"], target.name, message));
      end,

      target = function(sender, target, message, colorify)
        return
          colorify(sfmt("[%s]%s: %s", titles["tell"], sender.name, message));
      end,
    },
  }),

  Channel({
    name        = "yell",
    color       = { "bold", "red" },
    description = "Send a message to everyone in your area",
    audience    = AreaAudience(),
    formatter   = {
      sender = function(sender, target, message, colorify)
        return
          colorify(sfmt("[%s]%s: %s", titles["yell"], sender.name, message));
      end,

      target = function(sender, target, message, colorify)
        return
          colorify(sfmt("[%s]%s: %s"), titles["yell"], sender.name, message);
      end,
    },
  }),

  Channel({
    name        = "gtell",
    color       = { "bold", "green" },
    description = "Send a message to everyone in your group, anywhere in the game",
    audience    = PartyAudience(),
    formatter   = {
      sender = function(sender, target, message, colorify)
        return colorify(
                 sfmt("[%s]%s: %s", titles["gtell"], sender.name, message));
      end,

      target = function(sender, target, message, colorify)
        return colorify(
                 sfmt("[%s]%s: %s", titles["gtell"], sender.name, message));
      end,
    },
  }),

};
