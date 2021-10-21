local class     = require("pl.class")

local Logger    = require("core.Logger")
local QuestGoal = require("core.QuestGoal")
local tablex    = require("pl.tablex")
local wrapper   = require("core.lib.wrapper")

---@class BountyGoal : QuestGoal
local M         = class(QuestGoal)
function M:_init(quest, config, player)
  config = tablex.update({ title = "Locate NPC", npc   = false, home  = false },
                         config or {})
  self:super(quest, config, player)
  self.state = { found     = false, delivered = false }
  self:on("enterRoom", wrapper.bind(self._enterRoom, self))
end

function M:getProgress()
  local percent = self.state.found and 50 or 0
  if self.config.home then
    percent = percent + self.state.delivered and 50 or 0
  else
    percent = percent + 50
  end
  local dispaly = self.state.found and "Complete" or "Not Complete"
  return { percent = percent, dispaly = dispaly }
end

---@param room Room
function M:_enterRoom(room)
  if self.state.found then
    if room.entityReference == self.config.name then
      self.state.delivered = true
    end
    self:emit("progress", self:getProgress())
  else
    local located   = false
    local goalNpcId = self.config.npc
    if goalNpcId then
      tablex.foreach(room.npcs, function(_, npc)
        if npc.entityReference == goalNpcId then
          located = true
          npc:follow(self.player)
        end
      end)
    else
      Logger.error("Quest: BountyGoal [%q] does not have target npc defined",
                   self.config.title)
    end
    if located then self.state.found = true end
    self:emit("progress", self:getProgress())
  end
end

return M
