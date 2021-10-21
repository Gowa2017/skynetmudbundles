local B = require("core.Broadcast")

return {
  listeners = {
    questStart       = function(state)
      return function(self, quest)
        B.sayAt(self, "<blue>questStart")
        B.sayAt(self, "<red>Quest Started: !<red>");
        if quest.config.description then
          B.sayAt(self, B.line(80));
          B.sayAt(self, "<bold>" .. quest.config.description, 80);
        end

        if quest.config.rewards.length then
          B.sayAt(self);
          B.sayAt(self, "<b><yellow>" + B.center(80, "Rewards") + "");
          B.sayAt(self, "<b><yellow>" + B.center(80, "-------") + "");

          for _, reward in pairs(quest.config.rewards) do
            local rewardClass = state.QuestRewardManager:get(reward.type);
            B.sayAt(self, "  " ..
                      rewardClass.display(state, quest, reward.config, self));
          end
        end

        B.sayAt(self, B.line(80));
      end
    end,

    questProgress    = function(state)
      return function(self, quest, progress)
        B.sayAt(self, "<red><yellow> progress:" .. progress.percent);
      end
    end,

    questTurnInReady = function(state)
      return function(self, quest)
        B.sayAt(self,
                "<bold><yellow>${} ready to turn in!" .. quest.config.title);
      end
    end,

    questComplete    = function(state)
      return function(self, quest)
        B.sayAt(self, "<bold><yellow>Quest Complete: ${}!" .. quest.config.title);
        if quest.config.completionMessage then
          B.sayAt(self, B.line(80));
          B.sayAt(self, quest.config.completionMessage);
        end
      end
    end,

    questReward      = function(state)
      ---
      ---Player received a quest reward
      ---@param reward table Reward config _not_ an instance of QuestReward
      return function(self, reward)
        --- do stuff when the player receives a quest reward. Generally the Reward instance
        --- will emit an event that will be handled elsewhere and display its own message
        --- e.g., 'currency' or 'experience'. But if you want to handle that all in one
        --- place instead, or you'd like to show some supplemental message you can do that here
      end
    end,
  },

}
