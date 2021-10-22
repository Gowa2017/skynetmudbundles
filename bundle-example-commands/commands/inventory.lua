local Broadcast = require("core.Broadcast")
local wrapper   = require("core.lib.wrapper")
local tablex    = require("pl.tablex")
local sfmt      = string.format

local ItemUtil  = wrapper.loadBundleScript("lib/ItemUtil", "bundle-example-lib");

return {
  usage   = "inventory",
  command = function(state)
    return function(self, args, player)
      if not player.inventory or tablex.size(player.inventory.items) then
        return Broadcast.sayAt(player, "You aren't carrying anything.");
      end

      Broadcast.at(player, "You are carrying");
      if type(player.inventory:getMax()) == "number" then
        Broadcast.at(player,
                     sfmt(" (%q/%q)})", tablex.size(player.inventory.items),
                          player.inventory:getMax()));
      end
      Broadcast.sayAt(player, ":");

      -- TODO: Implement grouping
      for _, item in pairs(player.inventory.items) do
        Broadcast.sayAt(player, ItemUtil.display(item));
      end
    end
  end,
};
