local class     = require("pl.class")

local QuestGoal = require("core.QuestGoal")
local tablex    = require("pl.tablex")
local wrapper   = require("core.lib.wrapper")

---@class EquipGoal : QuestGoal
local M         = class(QuestGoal)

function M:_init(quest, config, player)
  config = tablex.update({ title = "Equip Item", slot  = nil }, config or {});
  self:super(quest, config, player);

  self.state = { equipped = false };

  self:on("equip", wrapper.bind(self._equipItem, self));
  self:on("unequip", wrapper.bind(self._unequipItem, self));
end

function M:getProgress()
  local percent = self.state.equipped and 100 or 0;
  local display = self.config.title ..
                    (not self.state.equipped and "Not " or "") .. "Equipped";
  return { percent = percent, display = display };
end

function M:_equipItem(slot, item)
  if slot ~= self.config.slot then return end
  self.state.equipped = true;
  self:emit("progress", self:getProgress());
end

function M:_unequipItem(slot, item)
  if slot ~= self.config.slot then return end
  self.state.equipped = false;
  self:emit("progress", self.getProgress());
end

return M
