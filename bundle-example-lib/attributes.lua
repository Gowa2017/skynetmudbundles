return {
  {
    name    = "mana",
    base    = 100,
    formula = {
      requires = { "intellect" },
      fn       = function(character, mana, intellect)
        return mana + (intellect * 10);
      end,
    },
  },
  { name = "favor", base = 10 },
  {
    name    = "health",
    base    = 100,
    formula = {
      requires = {},
      fn       = function(character, health)
        return health + character.level * 2;
      end,
    },
  },
  { name = "energy", base = 100 },
  { name = "strength", base = 0 },
  { name = "agility", base = 0 },
  { name = "intellect", base = 0 },
  { name = "stamina", base = 0 },
  { name = "armor", base = 0 },
  { name = "critical", base = 0 },
};
