local class     = require("pl.class")
local QuestGoal = require("core.QuestGoal")
local tablex    = require("pl.tablex")
local wrapper   = require("core.lib.wrapper")

---@class KillGoal : QuestGoal
local M         = class(QuestGoal)

function M:_init(quest, config, player)
  config = tablex.update({ title = "Kill Enemy", npc   = nil, count = 1 },
                         config or {});

  self:super(quest, config, player);

  self.state = { count = 0 };

  self:on("deathblow", wrapper.bind(self._targetKilled, self));
end

function M:getProgress()
  local percent = (self.state.count / self.config.count) * 100;
  local display = self.config.title .. ":" .. self.state.count .. "/" ..
                    self.config.count
  return { percent = percent, display = display };
end

function M:_targetKilled(target)
  if target.entityReference ~= self.config.npc or
    (self.state.count > self.config.count) then return end
  self.state.count = self.state.count + 1;
  self:emit("progress", self:getProgress());
end

return M
