return {
  {
    coordinates = {
      0,
      0,
      0
    },
    description = "You are in the start of this area. There are hallways to the north and south.",
    id = "start",
    npcs = {
      "mapped:squirrel"
    },
    title = "Begin"
  },
  {
    coordinates = {
      0,
      1,
      0
    },
    description = "You are in the north hallway.",
    id = "hallway-north-1",
    title = "Hallway North 1"
  },
  {
    coordinates = {
      0,
      2,
      0
    },
    description = "You are in the north hallway.",
    id = "hallway-north-2",
    title = "Hallway North 2"
  },
  {
    coordinates = {
      0,
      2,
      -1
    },
    description = "You are in the basement.",
    doors = {
      ["mapped:hallway-north-2"] = {
        closed = true
      }
    },
    id = "basement-north",
    title = "Basement"
  },
  {
    coordinates = {
      0,
      -1,
      0
    },
    description = "You are in the south hallway.",
    id = "hallway-south-1",
    title = "Hallway South 1"
  },
  {
    coordinates = {
      0,
      -2,
      0
    },
    description = "You are in the south hallway.",
    id = "hallway-south-2",
    title = "Hallway South 2"
  },
  {
    coordinates = {
      0,
      -2,
      1
    },
    description = "You are in the attic.",
    exits = {
      {
        direction = "east",
        roomId = "limbo:white"
      }
    },
    id = "attic-south",
    title = "Attic"
  },
  {
    coordinates = {
      1,
      0,
      0
    },
    description = "You are in the east hallway.",
    id = "hallway-east-1",
    title = "Hallway East 1"
  },
  {
    coordinates = {
      2,
      0,
      0
    },
    description = "You are in the east hallway.",
    id = "hallway-east-2",
    title = "Hallway East 2"
  },
  {
    coordinates = {
      2,
      -1,
      0
    },
    description = "You are in the east hallway.",
    id = "hallway-east-3",
    title = "Hallway East 3"
  }
}