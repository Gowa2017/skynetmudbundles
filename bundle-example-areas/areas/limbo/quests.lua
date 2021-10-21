return {
  {
    autoComplete      = true,
    completionMessage = [[<b><cyan>Hint: You can use the '<white>tnl or '<white>level' commands to see how much experience you need to level.
<b><yellow>The rat looks like it is hungry, use '<white>quest list rat to see what aid you can offer. Use '<white>quest start rat 1 to accept their task.
<b><cyan>Hint: To move around the game type any of the exit names listed in <white>[Exits: ...] when you use the '<white>look command.]],
    description       = [[A voice whispers to you: Welcome to the world, young one. This is a dangerous and deadly place, you should arm yourself.
 - Open the chest with '<white>open chest'
 - Use '<white>get sword chest and '<white>get vest chest to get some gear
 - Equip it using '<white>wield sword and '<white>wear vest']],
    goals             = {
      {
        config = {
          count = 1,
          item  = "limbo:rustysword",
          title = "Find a Weapon",
        },
        type   = "FetchGoal",
      },
      {
        config = {
          count = 1,
          item  = "limbo:leathervest",
          title = "Find Some Armor",
        },
        type   = "FetchGoal",
      },
      {
        config = { slot  = "wield", title = "Wield A Weapon" },
        type   = "EquipGoal",
      },
      {
        config = { slot  = "chest", title = "Equip Some Armor" },
        type   = "EquipGoal",
      },
    },
    id                = "journeybegins",
    level             = 1,
    rewards           = {
      {
        config = { amount    = 5, leveledTo = "QUEST" },
        type   = "ExperienceReward",
      },
      { config = { amount   = 10, currency = "gold" },
      type   = "CurrencyReward" },
    },
    title             = "A Journey Begins",
  },
  {
    completionMessage = "<b><cyan>Hint: NPCs with quests available have <white>[</white><yellow>!</yellow><white>]</white> in front of their name, <white>[</white><yellow>?</yellow><white>]</white> means you have a quest ready to turn in, and <white>[</white><yellow>%</yellow><white>]</white> means you have a quest in progress.</cyan>",
    description       = [[A rat's squeaks seem to indicate it wants some cheese. You check around the area, maybe someone has left some lying around.

Once you find some bring it back to the rat, use '<white>quest log</white>' to find the quest number, then complete the quest with '<white>quest complete #</white>']],
    goals             = {
      {
        config = {
          count      = 1,
          item       = "limbo:sliceofcheese",
          removeItem = true,
          title      = "Found Cheese",
        },
        type   = "FetchGoal",
      },
    },
    id                = "onecheeseplease",
    level             = 1,
    repeatable        = true,
    rewards           = {
      {
        config = { amount    = 3, leveledTo = "QUEST" },
        type   = "ExperienceReward",
      },
    },
    title             = "One Cheese Please",
  },
  {
    autoComplete      = true,
    completionMessage = "<b><cyan>Hint: You can get the loot from enemies with '<white>get <item> corpse</white>' but be quick about it, the corpse will decay after some time.</cyan>",
    description       = [[A voice whispers to you: It would be wise to practice protecting yourself. There are a number of training dummies in this area that, while not pushovers, will not be too difficult.
- Use '<white>attack dummy</white>' to start combat against the training dummy
- Once it's dead any loot it drops will be in its corpse on the ground. You can use '<white>look in corpse</white>' to check again or '<white>loot corpse</white>' to retrieve all your loot.]],
    goals             = {
      {
        config = {
          count = 1,
          npc   = "limbo:trainingdummy",
          title = "Kill a Training Dummy",
        },
        type   = "KillGoal",
      },
    },
    id                = "selfdefense101",
    level             = 2,
    requires          = { "limbo:journeybegins" },
    rewards           = {
      {
        config = { amount    = 5, leveledTo = "QUEST" },
        type   = "ExperienceReward",
      },
    },
    title             = "Self Defense 101",
  },
}
