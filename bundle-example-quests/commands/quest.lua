local B              = require("core.Broadcast")
local CommandManager = require("core.CommandManager")
local stringx        = require("pl.stringx")

local say            = B.sayAt;
local sfmt           = string.format
local tablex         = require("pl.tablex")

local wrapper        = require("core.lib.wrapper")

local ArgParser      = wrapper.loadBundleScript("lib/ArgParser",
                                                "bundle-example-lib");
---@type CommandManager
local subcommands    = CommandManager()
local function getAvailableQuests(state, player, npc)
  return tablex.filter(npc.quest, function(qref)
    return state.QuestFactory:canStart(player, qref) or
             player.questTracker:isActive(qref);

  end)
end

subcommands:add({
  name    = "list",
  command = function(state)
    return function(options, player)
      if not options or #options < 1 then
        return say(player, "List quests from whom? quest list {npc}");
      end

      local search          = options[1];
      local npc             = ArgParser.parseDot(search,
                                                 tablex.keys(player.room.npcs));
      if not npc then
        return say(player, sfmt("No quest giver [${search}] found.", search));
      end

      if not npc.quests then
        return say(player, sfmt("${npc.name} has no quests.", npc.name));
      end

      local availableQuests = getAvailableQuests(state, player, npc);

      if not availableQuests or #availableQuests < 1 then
        return say(player, sfmt("${npc.name} has no quests.", npc.name));
      end

      for i, qref in ipairs(availableQuests) do
        local quest = state.QuestFactory:get(qref);
        if state.QuestFactory:canStart(player, qref) then
          say(player,
              sfmt("[<bold><yellow>!] - ${displayIndex}. ${quest.config.title}",
                   i, quest.config.title));
        elseif player.questTracker:isActive(qref) then
          quest = player.questTracker.get(qref);
          local symbol = quest:getProgress().percent >= 100 and "?" or "%";
          say(player,
              sfmt(
                "[<bold><yellow>${symbol}] - ${displayIndex}. ${quest.config.title}",
                symbol, i, quest.config.title));
        end
      end
    end
  end,
});

subcommands:add({
  name    = "start",
  aliases = { "accept" },
  command = function(state)
    return function(options, player)
      if not options or #options < 2 then
        return say(player,
                   "Start which quest from whom? 'quest start {npc} {number}'");
      end

      local search          = options.search
      local questIndex      = tonumber(options.questIndex)

      local npc             = ArgParser.parseDot(search, player.room.npcs);
      if not npc then
        return say(player, sfmt("No quest giver [${search}] found.", search));
      end

      if not npc.quests or #npc.quests < 1 then
        return say(player, sfmt("${npc.name} has no quests.", npc.name));
      end

      if not questIndex or questIndex < 1 or questIndex > #npc.quests then
        return say(player, sfmt(
                     "Invalid quest, use 'quest list ${search}' to see their quests.",
                     search));
      end

      local availableQuests = getAvailableQuests(state, player, npc);

      local targetQuest     = availableQuests[questIndex];

      if player.questTracker:isActive(targetQuest) then
        return say(player,
                   "You've already started that quest. Use 'quest log' to see your active quests.");
      end

      local quest           = state.QuestFactory:create(state, targetQuest,
                                                        player);
      player.questTracker:start(quest);
      player:save();
    end
  end,
});

subcommands.add({
  name    = "log",
  command = function(state)
    return function(options, player)
      local active = player.questTracker.activeQuests
      if not active or tablex.size(active) < 1 then
        return say(player, "You have no active quests.");
      end

      local i      = 1
      for _, quest in active do
        local progress = quest:getProgress();

        B.at(player, "<bold><yellow>" .. tostring(i) .. ": ");
        say(player, B.progress(60, progress.percent, "yellow") ..
              tostring(progress.percent));
        say(player,
            B.indent("<bold><yellow>" .. quest.getProgress().display .. "", 2));

        if quest.config.npc then
          local npc = state.MobFactory:getDefinition(quest.config.npc);
          say(player, sfmt("  <bold><yellow>Questor: ${npc.name}", npc.name));
        end

        say(player, "  " .. B.line(78));
        say(player,
            B.indent(B.wrap(sfmt("<bold><yellow>${quest.config.description}",
                                 quest.config.description), 78), 2));

        if quest.config.rewards and #quest.config.rewards > 1 then
          say(player);
          say(player, "<bold><yellow>" .. B.center(80, "Rewards") .. "");
          say(player, "<bold><yellow>" .. B.center(80, "-------") .. "");

          for _, reward in ipairs(quest.config.rewards) do
            local rewardClass = state.QuestRewardManager:get(reward.type);
            say(player, "  " ..
                  rewardClass:display(state, quest, reward.config, player));
          end
        end
        say(player, "  " .. B.line(78));
      end
    end
  end,
});

--- use number index ..not key index ,so need modify
subcommands:add({
  name    = "complete",
  command = function(state)
    return function(options, player)
      local active      = player.questTracker.activeQuests
      local targetQuest = tonumber(options[1])
      targetQuest = targetQuest or -1
      if not active[targetQuest] then
        return say(player,
                   "Invalid quest, use 'quest log' to see your active quests.");
      end

      local quest       = active[targetQuest].quest;

      if quest:getProgress().percent < 100 then
        say(player, sfmt("${quest.config.title} isn't complete yet.",
                         quest.config.title));
        quest:emit("progress", quest:getProgress());
        return;
      end

      if quest.config.npc and
        not tablex.find_if(tablex.keys(player.room.npcs), function(npc)
          return npc.entityReference == quest.config.npc
        end) then
        local npc = state.MobFactory:getDefinition(quest.config.npc);
        return say(player, sfmt(
                     "The questor [${npc.name}] is not in this room.", npc.name));
      end

      quest:complete();
      player:save();
    end
  end,
});

return {
  usage   = "quest {log/list/complete/start} [npc] [number]",
  command = function(state)
    return function(self, args, player)
      if not args or #args < 1 then
        return say(player, "Missing command. See 'help quest'");
      end

      args = stringx.split(" ")
      local command    = args[1]
      local options    = tablex.icopy({}, args, 1, 2)

      local subcommand = subcommands:find(command);
      if not subcommand then
        return say(player, "Invalid command. See 'help quest'");
      end

      subcommand.command(state)(options, player);
    end
  end,
};
