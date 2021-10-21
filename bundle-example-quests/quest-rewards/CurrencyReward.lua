local class       = require("pl.class")

local QuestReward = require("core.QuestReward")
local tablex      = require("pl.tablex")
local sfmt        = string.format

---@class CurrencyReward : QuestReward
local M           = class(QuestReward)

---
--- Quest reward that gives experience
---
--- Config options:
---   currency: string, required, currency to award
---   amount: number, required
---
function M.reward(GameState, quest, config, player)
  local amount = M._getAmount(quest, config);
  player:emit("currency", config.currency, amount);
end
function M.display(GameState, quest, config, player)
  local amount = M._getAmount(quest, config);
  -- local friendlyName = config.currency.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase());

  return "Currency: <b>${amount}</b> x <b><white>[${friendlyName}]</white></b>";
end

function M._getAmount(quest, config)
  config = tablex.update({ amount   = 0, currency = nil }, config);

  if not config.currency then
    error(sfmt("Quest [%q] currency reward has invalid configuration", quest.id))
  end

  return config.amount;
end

return M
