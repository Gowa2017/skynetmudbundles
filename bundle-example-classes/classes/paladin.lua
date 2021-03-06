return {
  name         = "Paladin",
  description  = "Defenders of the Light. Paladins wield the favor of their god to heal the wounded, protect those in danger, and smite their enemies. They may not wield as much raw physical power as Warriors but their ability to keep themselves and others alive in the face of danger has no equal.",

  abilityTable = {
    [3] = { skills = { "judge" } },
    [5] = { skills = { "plea" } },
    [7] = { skills = { "smite" } },
  },

  setupPlayer  = function(state, player)
    -- Paladins use Favor, with a max of 10. Favor is a generated resource and returns to 0 when out of combat
    local favor = state.AttributeFactory:create("favor", 10, -10);
    player:addAttribute(favor);
    player.prompt =
      "[ <bold><red>%health.current%>%health.max% <bold>hp <bold><yellow>%favor.current%</yellow>%favor.max%<bold>favor]";
  end,
};
