local Broadcast = require("core.Broadcast")

return {
  command = function(state)
    return function(self, args, player)
      local previousPvpSetting = player:getMeta("pvp") or false;
      local newPvpSetting      = not previousPvpSetting;
      player:setMeta("pvp", newPvpSetting);

      local message            = newPvpSetting and
                                   "You are now able to enter into player-on-player duels." or
                                   "You are now a pacifist and cannot enter player-on-player duels.";
      Broadcast.sayAt(player, message);
    end
  end,
};
