-- local humanize = (sec) => { return require('humanize-duration')(sec, { round: true }); };
local sprintf   = string.format
local B         = require("core.Broadcast")
local Room      = require("core.Room")
local Item      = require("core.Item")
local ItemType  = require("core.ItemType")
local Logger    = require("core.Logger")
local Player    = require("core.Player")
local tablex    = require("pl.tablex")
local stringx   = require("pl.stringx")

local wrapper   = require("core.lib.wrapper")

local ArgParser =
  wrapper.loadBundleScript("lib/ArgParser", "bundle-example-lib");
local ItemUtil  = wrapper.loadBundleScript("lib/ItemUtil", "bundle-example-lib");

local function humanize(ms) return ms end
local function getCombatantsDisplay(entity)
  local combatantsList = { "<red>fighting " }
  for combatant, _ in pairs(entity.combatants) do
    combatantsList[#combatantsList + 1] = combatant.name

  end
  return table.concat(combatantsList, ",")
end
local function getCompass(player)
  ---@type Room
  local room                             = player.room;
  local exitMap                          = {}
  exitMap["east"] = "E"
  exitMap["west"] = "W"
  exitMap["south"] = "S"
  exitMap["north"] = "N"
  exitMap["up"] = "U"
  exitMap["down"] = "D"
  exitMap["southwest"] = "SW"
  exitMap["southeast"] = "SE"
  exitMap["northwest"] = "NW"
  exitMap["northeast"] = "NE"

  local directionsAvailable              =
    tablex.imap(function(exit) return exitMap[exit.direction] end, room.exits)

  local exits                            = {}
  for direction, DIR in pairs(exitMap) do
    if tablex.find(directionsAvailable, DIR) then
      exits[DIR] = DIR
      goto continue
    end
    if #DIR == 2 and DIR:find("E") then
      exits[DIR] = " -";
      goto continue
    end
    if #DIR == 2 and DIR:find("W") then
      exits[DIR] = "- ";
      goto continue
    end
    exits[DIR] = "-"
    ::continue::
  end

  local E, W, S, N, U, D, SW, SE, NW, NE = exits.E, exits.W, exits.S, exits.N,
                                           exits.U, exits.D, exits.SW, exits.SE,
                                           exits.NW, exits.NE
  U = U == "U" and "<yellow>U" or U;
  D = D == "D" and "<yellow>D" or D;

  local line1                            =
    string.format("%s     %s     %s", NW, N, NE);
  local line2                            = string.format(
                                             "<yellow>%s   %s-(@)-%s   <yellow>%s",
                                             W, U, D, E);
  local line3                            =
    string.format("%s     %s     %s\r\n", SW, S, SE);
  return line1, line2, line3
end

local function lookRoom(state, player)
  local room       = player.room;

  if player.room.coordinates then
    B.sayAt(player, "<yellow>" .. sprintf("%-65s", room.title));
    B.sayAt(player, B.line(60));
  else
    local line1, line2, line3 = getCompass(player);
    -- map is 15 characters wide, room is formatted to 80 character width
    B.sayAt(player, "<yellow>" .. sprintf("%-65s", room.title) .. line1);
    B.sayAt(player, B.line(60) .. B.line(5, " ") .. line2);
    B.sayAt(player, B.line(65, " ") .. "<yellow>" .. line3);
  end

  if not player:getMeta("config.brief") then
    B.sayAt(player, room.description, 80);
  end

  if player:getMeta("config.minimap") then
    B.sayAt(player, "");
    state.CommandManager:get("map"):execute(4, player);
  end

  B.sayAt(player, "");

  -- show all players
  for otherPlayer, _ in pairs(room.players) do
    if otherPlayer == player then goto continue end
    local combatantsDisplay = ""
    if otherPlayer:isInCombat() then
      combatantsDisplay = getCombatantsDisplay(otherPlayer)
    end
    B.sayAt(player, "[Player] " .. otherPlayer.name .. combatantsDisplay);
    ::continue::
  end

  -- show all the items in the rom
  ---@type Item
  for item, _ in pairs(room.items) do
    if item:hasBehavior("resource") then
      B.sayAt(player,
              string.format("[%s] <magenta> %s",
                            ItemUtil.qualityColorize(item, "Resource"),
                            item.roomDesc));
    else
      B.sayAt(player,
              string.format("[%s] <magenta>%s",
                            ItemUtil.qualityColorize(item, "Item"),
                            item.roomDesc));
    end
  end
  -- show all npcs
  for npc, _ in pairs(room.npcs) do
    -- show quest state as [!], [%], [?] for available, in progress, ready to complete respectively
    local hasNewQuest, hasActiveQuest, hasReadyQuest;
    if npc.quests then
      hasNewQuest = tablex.find_if(npc.quests, function(questRef)
        return state.QuestFactory:canStart(player, questRef) and questRef
      end)

      hasReadyQuest = tablex.find_if(npc.quests, function(questRef)
        return player.questTracker:isActive(questRef) and
                 player.questTracker:get(questRef):getProgress().percent >= 100;
      end);
      hasActiveQuest = tablex.find_if(npc.quests, function(questRef)
        return player.questTracker:isActive(questRef) and
                 player.questTracker:get(questRef):getProgress().percent < 100;
      end);

      local questString = "";
      if hasNewQuest or hasActiveQuest or hasReadyQuest then
        questString = questString .. (hasNewQuest and "[<yellow>!]" or "");
        questString = questString .. (hasActiveQuest and "[<yellow>%]" or "");
        questString = questString .. (hasReadyQuest and "[<yellow>?]" or "");
        B.at(player, questString .. " ");
      end
    end

    local combatantsDisplay                          = "";
    if npc:isInCombat() then combatantsDisplay = getCombatantsDisplay(npc); end

    -- color NPC label by difficulty
    local npcLabel                                   = "NPC";
    if player.level - npc.level > 4 then
      npcLabel = "<cyan>NPC";
    elseif npc.level - player.level > 9 then
      npcLabel = "<black>NPC";
    elseif npc.level - player.level > 5 then
      npcLabel = "<red>NPC";
    elseif npc.level - player.level > 3 then
      npcLabel = "<yellow>NPC";
    else
      npcLabel = "<green>NPC";
    end
    B.sayAt(player,
            string.format("%s %s %s", npcLabel, npc.name, combatantsDisplay))
  end

  B.at(player, "[<yellow>Exits: ");

  local exits      = room:getExits();

  local foundExits = {};

  -- prioritize explicit over inferred exits with the same name
  for _, exit in pairs(exits) do
    for _, fe in ipairs(foundExits) do
      if fe.direction == exit.direction then goto continue end
    end
    foundExits[#foundExits + 1] = exit
    ::continue::
  end

  local dsp        = tablex.imap(function(exit)
    local exitRoom = state.RoomManager:getRoom(exit.roomId)
    local door     = room:getDoor(exitRoom) or
                       (exitRoom and exitRoom:getDoor(room))
    if door and (door.locked or door.closed) then
      return string.format("(%s)", exit.direction)
    end
    return exit.direction
  end, foundExits)

  B.at(player, table.concat(dsp, " "))

  if #foundExits < 1 then B.at(player, "none"); end
  B.sayAt(player, "]");
end

local function lookEntity(state, player, args)
  local room   = player.room;
  args = stringx.split(args, " ")
  local search
  if #args > 1 then
    search = args[1] == "in" and args[2] or args[1];
  else
    search = args[1];
  end

  local entity = ArgParser.parseDot(search, tablex.keys(room.items));
  entity = entity or ArgParser.parseDot(search, tablex.keys(room.players));
  entity = entity or ArgParser.parseDot(search, tablex.keys(room.npcs));
  entity = entity or
             ArgParser.parseDot(search, tablex.values(player.inventory.items));

  if not entity then
    return B.sayAt(player, "You don't see anything like that here.");
  end

  if Player:class_of(entity) then
    -- TODO: Show player equipment?
    B.sayAt(player, string.format("You see fellow player %s.", entity.name));
    return;
  end

  B.sayAt(player, entity.description, 80);

  if entity.timeUntilDecay then
    B.sayAt(player,
            string.format("You estimate that %q will rot away in %q.",
                          entity.name, humanize(entity.timeUntilDecay)));
  end

  local usable = entity:getBehavior("usable");
  if usable then
    if usable.spell then
      local useSpell = state.SpellManager:get(usable.spell);
      if useSpell then
        useSpell.options = usable.options;
        B.sayAt(player, useSpell:info(player));
      end
    end

    if usable.effect and usable.config.description then
      B.sayAt(player, usable.config.description);
    end

    if usable.charges then
      B.sayAt(player,
              string.format("There are %q charges remaining.", usable.charges));
    end
  end

  if Item:class_of(entity) then
    if entity.type == ItemType.WEAPON or entity.type == ItemType.WEAPON then
      return B.sayAt(player, ItemUtil.renderItem(state, entity, player));
    elseif entity.type == ItemType.CONTAINER then
      if not entity.inventory or tablex.size(entity.inventory.items) < 1 then
        return B.sayAt(player, string.format("%q is empty.", entity.name));
      end

      if entity.closed then return B.sayAt(player, "It is closed."); end

      B.at(player, "Contents");
      if entity.inventory:getMax() ~= math.maxinteger then
        B.at(player,
             string.format(" (%q/%q)})", tablex.size(entity.inventory.items),
                           entity.inventory:getMax()));
      end
      B.sayAt(player, ":");

      for _, item in ipairs(entity.inventory.items) do
        B.sayAt(player, "  " .. ItemUtil.display(item));
      end
    end
  end
end

return {
  usage   = "look [thing]",
  command = function(state)
    return function(self, args, player)
      if not player.room or not Room:class_of(player.room) then
        Logger.error(player.name .. " is in limbo.");
        return B.sayAt(player, "You are in a deep, dark void.");
      end

      if args and #args > 0 then return lookEntity(state, player, args); end

      lookRoom(state, player);
    end
  end,
};
