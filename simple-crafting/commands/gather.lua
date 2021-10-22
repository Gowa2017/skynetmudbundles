local B         = require("core.Broadcast")
local wrapper   = require("core.lib.wrapper")
local tablex    = require("pl.tablex")

local ArgParser =
  wrapper.loadBundleScript("lib/ArgParser", "bundle-example-lib");
local ItemUtil  = wrapper.loadBundleScript("lib/ItemUtil", "bundle-example-lib");
local Crafting  = wrapper.loadBundleScript("lib/Crafting");

return {
  command = function(state)
    return function(self, args, player)
      if not args or #args < 1 then return B.sayAt(player, "Gather what?"); end

      local node     = ArgParser.parseDot(args, tablex.keys(player.room.items));

      if not node then
        return B.sayAt(player, "You don't see anything like that here.");
      end

      local resource = node:getMeta("resource");
      if not resource then
        return B.sayAt(player, "You can't gather anything from that.");
      end

      if player:getMeta("resources") then player:setMeta("resources", {}); end

      for _, material in ipairs(resource.materials) do
        local entry  = resource.materials[material];
        local amount = math.random(entry.min, entry.max);
        if amount then
          local resItem = Crafting.getResourceItem(material);
          local metaKey = "resources." .. material;
          player:setMeta(metaKey, (player:getMeta(metaKey) or 0) + amount);
          B.sayAt(player, string.format("<green>You gather: %s x%q.",
                                        ItemUtil.display(resItem), amount));
        end
      end

      -- destroy node, will be respawned
      state.ItemManager:remove(node);
      B.sayAt(player, string.format("%s %s", ItemUtil.display(node),
                                    resource.depletedMessage));
      node = nil;
    end
  end,
};
