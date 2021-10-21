local class       = require("pl.class")

local QuestReward = require("core.QuestReward")
-- local LevelUtil   = require("bundle-example-lib/lib/LevelUtil");
---@class ExperienceReward : QuestReward
local tablex      = require("pl.tablex")
local M           = class(QuestReward)

---*
--- Quest reward that gives experience
---
--- Config options:
---   amount: number, default: 0, Either a static amount or a multipler to use for leveledTo
---   leveledTo: "PLAYER"|"QUEST", default: null, If set scale the amount to either the quest's or player's level
---
--- Examples:
---
---   Gives equivalent to 5 times mob xp for a mob of the quests level
---     amount: 5
---     leveledTo: quest
---
---   Gives a static 500 xp
---     amount: 500
---
function M.reward(GameState, quest, config, player)
  local amount = M._getAmount(quest, config, player);
  player:emit("experience", amount);
end

function M.display(GameState, quest, config, player)
  local amount = M._getAmount(quest, config, player);
  return "Experience: <b>${amount}</b>";
end

function M._getAmount(quest, config, player)
  config = tablex.update({ amount    = 0, leveledTo = nil }, config);

  local amount = config.amount;
  if config.leveledTo then
    local level = config.leveledTo == "PLAYER" and player.level or
                    quest.config.level
    -- amount = LevelUtil.mobExp(level) * amount
  end

  return amount;
end
return M
