local B        = require("core.Broadcast")
local wrapper  = require("core.lib.wrapper")
local Crafting = wrapper.loadBundleScript("lib/Crafting");
local ItemUtil = wrapper.loadBundleScript("lib/ItemUtil", "bundle-example-lib");

return {
  aliases = { "materials" },
  command = function(state)
    return function(self, args, player)
      local playerResources = player:getMeta("resources");

      if not playerResources then
        return B.sayAt(player, "You haven't gathered any resources.");
      end

      B.sayAt(player, "<bold>Resources");
      B.sayAt(player, B.line(40));
      local totalAmount     = 0;
      for _, resourceKey in ipairs(playerResources) do
        local amount  = playerResources[resourceKey];
        totalAmount = totalAmount + amount;

        local resItem = Crafting.getResourceItem(resourceKey);
        B.sayAt(player,
                string.format("%s x %q", ItemUtil.display(resItem), amount));
      end

      if not totalAmount then
        return B.sayAt(player, "You haven't gathered any resources.");
      end
    end
  end,
};
