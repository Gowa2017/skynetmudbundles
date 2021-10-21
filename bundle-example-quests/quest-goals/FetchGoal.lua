local class     = require("pl.class")
local QuestGoal = require("core.QuestGoal")
local tablex    = require("pl.tablex")
local wrapper   = require("core.lib.wrapper")

---@class FetchGoal : QuestGoal
local M         = class(QuestGoal)

function M:_init(quest, config, player)
  config = tablex.update({
    title      = "Retrieve Item",
    removeItem = false,
    count      = 1,
    item       = nil,
  }, config or {});

  self:super(quest, config, player);

  self.state = { count = 0 };

  self:on("get", wrapper.bind(self._getItem, self));
  self:on("drop", wrapper.bind(self._dropItem, self));
  self:on("decay", wrapper.bind(self._dropItem, self));
  self:on("start", wrapper.bind(self._checkInventory, self));
end

function M:getProgress()
  local amount  = math.min(self.config.count, self.state.count);
  local percent = (amount / self.config.count) * 100;
  local display = self.config.title .. ":" .. tostring(self.state.count)
  return { percent = percent, display = display };
end

function M:complete()
  if self.state.count < self.config.count then return end

  local player = self.quest.player;
  if self.config.removeItem then
    for i = 1, self.config.count do
      for _, item in pairs(player.inventory.items) do
        self.quest.GameState.ItemManager:remove(item)
        break
      end
    end
  end

  QuestGoal:complete();
end

function M:_getItem(item)

  if item.entityReference ~= self.config.item then return end
  self.state.count = (self.state.count or 0) + 1

  if self.state.count > self.config.count then return end
  self.emit("progress", self.getProgress());
end

function M:_dropItem(item)
  if not self.state.count or item.entityReference ~= self.config.item then
    return
  end

  self.state.count = select.state.count - 1

  if self.state.count >= self.config.count then return end
  self:emit("progress", self.getProgress());
end

function M:_checkInventory()
  -- when the quest is first started check the player's inventory for items they need
  if not self.player.inventory then return end

  for _, item in ipairs(self.player.inventory.items) do self:_getItem(item) end
end
return M
