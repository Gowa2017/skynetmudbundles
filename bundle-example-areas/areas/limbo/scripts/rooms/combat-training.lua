return {
  listeners = {
    playerEnter = function(state)
      return function(self, player)
        local questRef = "limbo:selfdefense101";
        if state.QuestFactory:canStart(player, questRef) then
          local quest = state.QuestFactory:create(state, questRef, player)
          player.questTracker:start(quest)
        end
      end
    end,
  },
};
