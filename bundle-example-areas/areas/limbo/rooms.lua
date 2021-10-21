return {
  {
    description = "A featureless white room. A pitch black void in the shape of archway can be seen on the east side of the room.",
    exits       = {
      {
        direction    = "east",
        leaveMessage = " steps into the void and disappears.",
        roomId       = "limbo:black",
      },
      { direction = "down", roomId    = "limbo:ancientwayshrine" },
      { direction = "west", roomId    = "limbo:wallys" },
      { direction = "north", roomId    = "mapped:start" },
    },
    id          = "white",
    items       = {
      {
        id               = "limbo:woodenchest",
        replaceOnRespawn = true,
        respawnChance    = 20,
      },
      {
        id               = "limbo:woodenchest",
        replaceOnRespawn = true,
        respawnChance    = 20,
      },
    },
    npcs        = { "limbo:rat" },
    script      = "white",
    title       = "White Room",
  },
  {
    description = "A completely black room. Somehow all of the light that should be coming from the room to the west does not pass through the archway. A single lightbulb hangs from the ceiling illuminating a small area. To the east you see a large white dome. There is a sign above the entrance to the dome: \"Training Area\"",
    exits       = {
      {
        direction    = "west",
        leaveMessage = " steps into the light and disappears.",
        roomId       = "limbo:white",
      },
      { direction = "east", roomId    = "limbo:training1" },
    },
    id          = "black",
    items       = {
      { id            = "limbo:sliceofcheese", respawnChance = 10 },
    },
    npcs        = { "limbo:wiseoldman", "limbo:puppy" },
    script      = "black",
    title       = "Black Room",
  },
  {
    description = "The entire area is covered by a large dome with a hexagonal grid surface. A beautiful blue sky reaches from horizon to horizon, punctuated by the lines of the grid. The dome shimmers as virtual birds fly into and out of its surface. The pure green grass is eerily undisturbed by you walking over it or by the simulated breeze.",
    exits       = {
      { direction = "west", roomId    = "limbo:black" },
      { direction = "north", roomId    = "limbo:training2" },
      { direction = "east", roomId    = "limbo:training4" },
    },
    id          = "training1",
    npcs        = {
      {
        id            = "limbo:trainingdummy",
        maxLoad       = 3,
        respawnChance = 25,
      },
    },
    script      = "combat-training",
    title       = "Training Room",
  },
  {
    description = "The entire area is covered by a large dome with a hexagonal grid surface. A beautiful blue sky reaches from horizon to horizon, punctuated by the lines of the grid. The dome shimmers as virtual birds fly into and out of its surface. The pure green grass is eerily undisturbed by you walking over it or by the simulated breeze.",
    exits       = {
      { direction = "south", roomId    = "limbo:training1" },
      { direction = "east", roomId    = "limbo:training3" },
    },
    id          = "training2",
    items       = { { id            = "craft:greenplant", respawnChance = 30 } },
    npcs        = {
      {
        id            = "limbo:trainingdummy",
        maxLoad       = 3,
        respawnChance = 25,
      },
      {
        id            = "limbo:aggro-player-test",
        maxLoad       = 1,
        respawnChance = 25,
      },
    },
    script      = "combat-training",
    title       = "Training Room 2",
  },
  {
    description = "The entire area is covered by a large dome with a hexagonal grid surface. A beautiful blue sky reaches from horizon to horizon, punctuated by the lines of the grid. The dome shimmers as virtual birds fly into and out of its surface. The pure green grass is eerily undisturbed by you walking over it or by the simulated breeze.",
    exits       = {
      { direction = "west", roomId    = "limbo:training2" },
      { direction = "south", roomId    = "limbo:training4" },
      { direction = "north", roomId    = "limbo:bosstraining" },
    },
    id          = "training3",
    items       = { { id            = "craft:redrose", respawnChance = 15 } },
    npcs        = {
      {
        id            = "limbo:trainingdummy",
        maxLoad       = 3,
        respawnChance = 25,
      },
    },
    script      = "combat-training",
    title       = "Training Room 3",
  },
  {
    description = "The entire area is covered by a large dome with a hexagonal grid surface. A beautiful blue sky reaches from horizon to horizon, punctuated by the lines of the grid. The dome shimmers as virtual birds fly into and out of its surface. The pure green grass is eerily undisturbed by you walking over it or by the simulated breeze.",
    exits       = {
      { direction = "west", roomId    = "limbo:training1" },
      { direction = "north", roomId    = "limbo:training3" },
    },
    id          = "training4",
    npcs        = {
      {
        id            = "limbo:trainingdummy",
        maxLoad       = 3,
        respawnChance = 25,
      },
      {
        id            = "limbo:aggro-npc-test",
        maxLoad       = 2,
        respawnChance = 50,
      },
    },
    script      = "combat-training",
    title       = "Training Room 4",
  },
  {
    description = "The dome in this section is bright red, the pure green grass is replaced with a smooth white surface. The ground beneath your feet has the word \"Danger\" in bright red letters tiled across the area.",
    exits       = { { direction = "south", roomId    = "limbo:training3" } },
    id          = "bosstraining",
    npcs        = { { id            = "limbo:bossdummy", respawnChance = 50 } },
    title       = "Boss Training Room",
  },
  {
    description = [[A runed black obelisk towers in the center of this clearing, surrounded by a faerie ring. The runes pulse and glow with a soft blue light. The grass immediately around the obelisk is immaculate in stark contrast to the dying former meadow that makes up the clearing.
]],
    exits       = {
      { direction = "up", roomId    = "limbo:white" },
      { direction = "down", roomId    = "limbo:context" },
    },
    id          = "ancientwayshrine",
    script      = "ancientwayshrine",
    title       = "Ancient Wayshrine",
  },
  {
    description = "A very brightly colored shop stall stands in the middle of an otherwise desolate clearing. The stall is covered in colorful cloth, shining gems, and battle gear of all varieties. A large sign sits next to the products: \"<yellow>Wally's Wonderful Wares has the best products in town! Armor, weapons and potions, you name and we... might have it!\"",
    exits       = { { direction = "east", roomId    = "limbo:white" } },
    id          = "wallys",
    npcs        = {
      { id            = "limbo:wallythewonderful", respawnChance = 0 },
    },
    title       = "Wally's Wonderful Wares (Shop)",
  },
  {
    description = "This room shows off commands that are only active in a particular room. Try out the <cyan>roomtest command.",
    doors       = {
      ["limbo:ancientwayshrine"] = { closed = true, locked = true },
    },
    exits       = {
      { direction = "up", roomId    = "limbo:ancientwayshrine" },
      { direction = "east", roomId    = "limbo:locked" },
    },
    id          = "context",
    items       = { { id = "limbo:test_key" } },
    metadata    = { commands = { "roomtest" } },
    script      = "context",
    title       = "Room Context Commands Test",
  },
  {
    description = "This room requires a key to get into",
    doors       = {
      ["limbo:context"] = {
        closed   = true,
        locked   = true,
        lockedBy = "limbo:test_key",
      },
    },
    exits       = { { direction = "west", roomId    = "limbo:context" } },
    id          = "locked",
    items       = {
      {
        id               = "limbo:locked_chest",
        replaceOnRespawn = true,
        respawnChance    = 5,
      },
    },
    title       = "Locked room with key",
  },
}
