return {
  name         = "Mage",
  description  = "Mages spend years learning to harness arcane forces to impose their will on the world around them. As scholars, they tend to be less brawny than Warriors and less stout than Clerics. Their powerful spells keep them alive and allow them to wreak havoc... as long as they have the mana to cast them.",
  abilityTable = { [5] = { spells = { "fireball" } } },

  setupPlayer  = function(state, player)
    local mana = state.AttributeFactory:create("mana", 100);
    player:addAttribute(mana);
    player.prompt =
      "[ %health.current%/%health.max% <bold>hp %mana.current%/%mana.max% <bold>mana ]";
  end,
};