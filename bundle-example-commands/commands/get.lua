local Broadcast = require("core.Broadcast")
local ItemType  = require("core.ItemType")
local stringx   = require("pl.stringx")
local tablex    = require("pl.tablex")
local sfmt      = string.format

local wrapper   = require("core.lib.wrapper")

local ArgParser =
  wrapper.loadBundleScript("lib/ArgParser", "bundle-example-lib");
local ItemUtil  = wrapper.loadBundleScript("lib/ItemUtil", "bundle-example-lib");

local function pickup(item, container, player)
  if item.metadata.noPickup then
    return Broadcast.sayAt(player, sfmt("%s can't be picked up.",
                                        ItemUtil.display(item)));
  end

  if container then
    container:removeItem(item);
  else
    player.room:removeItem(item);
  end

  player:addItem(item);

  Broadcast.sayAt(player, sfmt("<green>You receive loot: %s<green>.",
                               ItemUtil.display(item)));
  item:emit("get", player);
  player:emit("get", item);
end

return {
  usage   = "get item [container]",
  aliases = { "take", "pick", "loot" },
  command = function(state)
    return function(self, args, player, arg0)
      if not args or #args < 1 then
        return Broadcast.sayAt(player, "Get what?");
      end

      if not player.room then
        return Broadcast.sayAt(player,
                               "You are floating in the nether, there is nothing to get.");
      end

      if player:isInventoryFull() then
        return Broadcast.sayAt(player, "You can't hold any more items.");
      end

      -- 'loot' is an alias for 'get all'
      if arg0 == "loot" then args = wrapper.trim("all " .. args) end

      -- get 3.foo from bar -> get 3.foo bar
      local parts                     = tablex.filter(stringx.split(args, " "),
                                                      function(arg)
        return not arg:find("from")
      end);

      -- pick up <item>
      if #parts > 1 and parts[1] == "up" then table.remove(parts, 2) end

      local source, search, container
      if #parts == 1 then
        search = parts[1];
        source = tablex.keys(player.room.items);
      else
        -- Newest containers should go first, so that if you type get all corpse you get from the
        -- most recent corpse. See issue #247.
        container = ArgParser.parseDot(parts[1], tablex.keys(player.room.items));
        if not container then
          return Broadcast.sayAt(player,
                                 "You don't see anything like that here.");
        end

        if container.type ~= ItemType.CONTAINER then
          return Broadcast.sayAt(player, sfmt("%s isn't a container.",
                                              ItemUtil.display(container)));
        end

        if container.closed then
          return Broadcast.sayAt(player, sfmt("%s is closed.",
                                              ItemUtil.display(container)));
        end

        search = parts[1];
        source = tablex.values(container.inventory.items);
      end

      if search == "all" then
        if not source or #source < 1 then
          return Broadcast.sayAt(player, "There isn't anything to take.");
        end

        for _, item in ipairs(source) do

          -- account for Set vs Map source
          if type(item) == "table" then item = item[2]; end

          if player:isInventoryFull() then
            return Broadcast.sayAt(player, "You can't carry any more.");
          end

          pickup(item, container, player);
        end
        return;
      end

      local item                      = ArgParser.parseDot(search, source);
      if not item then
        return Broadcast.sayAt(player, "You don't see anything like that here.");
      end

      pickup(item, container, player);
    end
  end,
};
