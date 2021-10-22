local wrapper        = require("core.lib.wrapper")
local stringx        = require("pl.stringx")

local sprintf        = string.format
local B              = require("core.Broadcast")
local CommandManager = require("core.CommandManager")
local ItemType       = require("core.ItemType")

local Crafting       = wrapper.loadBundleScript("lib/Crafting");
local say            = B.sayAt;
local ItemUtil       = wrapper.loadBundleScript("lib/ItemUtil",
                                                "bundle-example-lib");

---@type CommandManager
local subcommands    = CommandManager();
local function getCraftingCategories(state)
  local craftingCategories = {
    { type  = ItemType.POTION, title = "Potion", items = {} },
    { type  = ItemType.WEAPON, title = "Weapon", items = {} },
    { type  = ItemType.ARMOR, title = "Armor", items = {} },
  };

  local recipes            = Crafting.getRecipes();
  for _, recipe in ipairs(recipes) do
    local recipeItem = state.ItemFactory:create(
                         state.AreaManager:getAreaByReference(recipe.item),
                         recipe.item);

    local catIndex  
    for index, cat in ipairs(craftingCategories) do
      if cat.type == recipeItem.type then
        catIndex = index
        break
      end
    end

    if not catIndex then goto continue end

    recipeItem:hydrate(state);
    craftingCategories[catIndex].items[#craftingCategories[catIndex].items + 1] =
      { item   = recipeItem, recipe = recipe.recipe };
    ::continue::
  end

  return craftingCategories;
end

-- /** LIST **/
subcommands:add({
  name    = "list",
  command = function(state)
    return function(self, args, player)
      local craftingCategories       = getCraftingCategories(state);

      -- list categories
      if not args or #args < 1 then
        say(player, "<bold>Crafting Categories");
        say(player, B.line(40));
        for index, category in ipairs(craftingCategories) do
          say(player, sprintf("%2d) %s", tonumber(index),
                              craftingCategories[index].title));
        end
      end

      local argList                  = stringx.split(args, " ")
      local itemCategory, itemNumber = argList[1], argList[2]

      itemCategory = tonumber(itemCategory)
      local category                 = craftingCategories[itemCategory];
      if not category then return say(player, "Invalid category."); end

      -- list items within a category
      itemNumber = tonumber(itemNumber)
      if not itemNumber then
        say(player, sprintf("<bold>${category.title}", category.title));
        say(player, B.line(40));

        if not category.items or #category.items < 1 then
          return say(player, B.center(40, "No recipes."));
        end

        for index, categoryEntry in ipairs(category) do
          say(player,
              sprintf("%2d) ", index) .. ItemUtil.display(categoryEntry.item));
        end
        return
      end

      local item                     = category.items[itemNumber];
      if not item then return say(player, "Invalid item."); end

      say(player, ItemUtil.renderItem(state, item.item, player));
      say(player, "<bold>Recipe:");
      for resource, amount in pairs(item.recipe) do
        local ingredient = Crafting.getResourceItem(resource);
        say(player, sprintf("  %s x %q", ItemUtil.display(ingredient), amount));
      end
    end
  end,
});

-- /** CREATE **/
subcommands:add({
  name    = "create",
  command = function(state)
    return function(self, args, player)
      if not args or #args < 1 then
        return say(player, "Create what? 'craft create 1 1' for example.");
      end

      local isInvalidSelection        = function(categoryList)
        return function(category)
          return not category or category < 0 or category > #categoryList
        end
      end

      local craftingCategories        = getCraftingCategories(state);
      local isInvalidCraftingCategory = isInvalidSelection(craftingCategories);

      local argList                   = stringx.split(args, " ")
      local itemCategory, itemNumber  = argList[1], argList[2]

      if isInvalidCraftingCategory(itemCategory) then
        return say(player, "Invalid category.");
      end

      local category                  = craftingCategories[itemCategory];
      local isInvalidCraftableItem    = isInvalidSelection(category.items);
      itemNumber = tonumber(itemNumber)
      if isInvalidCraftableItem(itemNumber) then
        return say(player, "Invalid item.");
      end

      local item                      = category.items[itemNumber];
      -- check to see if player has resources available
      for resource, recipeRequirement in pairs(item.recipe) do
        local playerResource = player:getMeta("resources." .. resource) or 0;
        if playerResource < recipeRequirement then
          return say(player, sprintf(
                       "You don't have enough resources. 'craft list %s' to see recipe. You need %q more %q.",
                       args, recipeRequirement - playerResource, resource));
        end

      end

      if player:isInventoryFull() then
        return say(player, "You can't hold any more items.");
      end

      -- deduct resources
      for resource, amount in pairs(item.recipe) do
        player:setMeta("resources." .. resource,
                       player:getMeta("resources." .. resource) - amount);
        local resItem = Crafting.getResourceItem(resource);
        say(player, sprintf("<green>You spend %q x %s.", amount,
                            ItemUtil.display(resItem)));
      end

      state.ItemManager:add(item.item);
      player:addItem(item.item);
      say(player,
          sprintf("<bold><green>You create: %s.", ItemUtil.display(item.item)));
      player:save();
    end
  end,
});

return {
  usage   = "craft {list/create} [category #] [item #]",
  command = function(state)
    return function(self, args, player)
      if not args or #args < 1 then
        return say(player, "Missing craft command. See 'help craft'");
      end

      local argList    = stringx.split(args, " ")
      local command    = #argList < 1 and args

      local subcommand = subcommands:find(command);
      if not subcommand then
        return say(player, "Invalid command. Use craft list or craft create.");
      end

      subcommand:command(state)(
        #argList > 1 and table.concat(argList, " ", 2) or "", player);
    end
  end,
};
