local Broadcast = require("core.Broadcast")
local wrapper   = require("core.lib.wrapper")

local sfmt      = string.format

LevelUtil = wrapper.loadBundleScript("lib/LevelUtil", "bundle-example-lib");

return {
  aliases = { "level", "experience" },
  usage   = "tnl",
  command = function(state)
    return function(self, args, player)
      local totalTnl    = LevelUtil.expToLevel(player.level + 1);
      local currentPerc = player.experience and
                            math.floor((player.experience / totalTnl) * 100) or
                            0;

      Broadcast.sayAt(player, sfmt("Level: %q", player.level));
      Broadcast.sayAt(player, Broadcast.progress(80, currentPerc, "blue"));
      Broadcast.sayAt(player,
                      sfmt("%q/%q (%q, %q til next level)", player.experience,
                           totalTnl, currentPerc, totalTnl - player.experience));
    end
  end,
};
