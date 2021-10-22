return {
  {
    name    = "mana",
    base    = 100,
    formula = {
      requires = { "intellect" },
      fn       = function(character, mana, intellect)
        return mana + (intellect * 10)
      end,
    },
  },
  { name = "favor", base = 10 },
}
