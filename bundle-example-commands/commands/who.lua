local B           = require("core.Broadcast")
local sfmt        = string.format
local tablex      = require("pl.tablex")
local roleStrings = { "", "<white>[Builder]", "<bold><white>[Admin]" }

local function getRoleString(role)
  role = role or 1
  return roleStrings[role] or ""
end

return {
  usage   = "who",
  command = function(state)
    return function(self, args, player)
      B.sayAt(player, "<bold><red>                  Who's Online");
      B.sayAt(player,
              "<bold><red>===============================================");
      B.sayAt(player, "");

      for _, otherPlayer in ipairs(state.PlayerManager.players) do
        B.sayAt(player, sfmt("* %s %s", otherPlayer.name,
                             getRoleString(otherPlayer.role)))
      end

      B.sayAt(player, tablex.size(state.PlayerManager.players) .. " total");

    end
  end,
};
