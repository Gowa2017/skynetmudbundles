return {
  {
    attributes = {
      energy = 100,
      health = 100
    },
    behaviors = {
      combat = true,
      ["ranvier-wander"] = {
        interval = 20,
        restrictTo = {
          "limbo:white",
          "limbo:black",
          "limbo:training1"
        }
      }
    },
    description = "The rat's beady red eyes dart frantically, its mouth foaming as it scampers about.",
    id = "rat",
    items = {
      "limbo:sliceofcheese"
    },
    keywords = {
      "rat"
    },
    level = 2,
    name = "A Rat",
    quests = {
      "limbo:onecheeseplease"
    },
    script = "rat"
  },
  {
    description = "A wise looking old man sits on the ground with legs crossed.",
    id = "wiseoldman",
    keywords = {
      "wise",
      "old",
      "man"
    },
    level = 99,
    name = "Wise Old Man",
    script = "old-man"
  },
  {
    description = "A wide-eyed puppy stares up at you.",
    id = "puppy",
    keywords = {
      "puppy",
      "dog",
      "loyal",
      "wide",
      "eyed",
      "wide-eyed"
    },
    level = 1,
    name = "A Puppy",
    script = "puppy"
  },
  {
    attributes = {
      health = 100,
      strength = 10
    },
    behaviors = {
      combat = true,
      lootable = {
        currencies = {
          gold = {
            max = 20,
            min = 10
          }
        },
        pools = {
          "limbo:junk",
          "limbo:potions",
          {
            ["limbo:sliceofcheese"] = 25
          }
        }
      }
    },
    description = "The training dummy is almost human shaped although slightly out of proportion. The material it's made of is hard to discern; it seems to constantly change between metal, wood, cloth, and glass depending on the angle. There is a large red and white bullseye painted on its chest. The dummy has no eyes and mindlessly meanders about the area.",
    id = "trainingdummy",
    keywords = {
      "dummy",
      "target",
      "practice"
    },
    level = 2,
    name = "Training Dummy"
  },
  {
    attributes = {
      health = 200,
      strength = 15
    },
    behaviors = {
      combat = true,
      lootable = {
        currencies = {
          gold = {
            max = 100,
            min = 50
          }
        },
        pools = {
          "limbo:potions",
          {
            ["limbo:trainingsword"] = 100
          },
          {
            ["limbo:bladeofranvier"] = 5
          }
        }
      }
    },
    description = "This dummy is significantly larger than the others. Bright red with a monstrous figure it lumbers around the area with a great echoing stomp. Where the other target dummies have a bullseye this dummy has a yellow exclamation mark.",
    id = "bossdummy",
    keywords = {
      "boss",
      "target",
      "dummy",
      "practice"
    },
    level = 5,
    name = "Boss Training Dummy"
  },
  {
    description = "Moe's Shop has the best wares in town! Armor, weapons and potions, you name and we ... might have it!",
    id = "wallythewonderful",
    keywords = {
      "wally",
      "wonderful",
      "shop",
      "vendor"
    },
    level = 99,
    metadata = {
      vendor = {
        enterMessage = "Step right up! Get your wares at Moe's Shop!",
        items = {
          ["limbo:bladeofranvier"] = {
            cost = 99999,
            currency = "gold"
          },
          ["limbo:leathervest"] = {
            cost = 30,
            currency = "gold"
          },
          ["limbo:potionhealth1"] = {
            cost = 100,
            currency = "gold"
          },
          ["limbo:potionstrength1"] = {
            cost = 150,
            currency = "gold"
          },
          ["limbo:trainingsword"] = {
            cost = 30,
            currency = "gold"
          },
          ["limbo:woodenshield"] = {
            cost = 30,
            currency = "gold"
          }
        },
        leaveMessage = "Come back soon!"
      }
    },
    name = "Wally the Wonderful"
  },
  {
    attributes = {
      health = 120,
      strength = 12
    },
    behaviors = {
      combat = true,
      ["ranvier-aggro"] = {
        delay = 5
      }
    },
    description = "This NPC is aggressive towards players but not other NPCs. Be careful.",
    id = "aggro-player-test",
    keywords = {
      "test",
      "aggro",
      "dummy"
    },
    level = 2,
    name = "Player-aggressive Training Dummy"
  },
  {
    attributes = {
      health = 100,
      strength = 15
    },
    behaviors = {
      combat = true,
      ["ranvier-aggro"] = {
        delay = 5,
        towards = {
          npcs = {
            "limbo:aggro-npc-test"
          },
          players = false
        }
      }
    },
    description = "This NPC is aggressive towards other NPCs but not to the player.",
    id = "aggro-npc-test",
    keywords = {
      "test",
      "aggro",
      "dummy"
    },
    level = 2,
    name = "Self-hating Training Dummy"
  }
}