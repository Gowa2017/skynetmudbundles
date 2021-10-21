return {
  {
    description = "An arm's-length, jagged metal sword discolored with red corrosion. The worn leather grip barely held on by fraying thread.",
    id          = "rustysword",
    keywords    = { "sword", "rusty", "metal", "rusted" },
    metadata    = {
      itemLevel = 1,
      level     = 1,
      maxDamage = 15,
      minDamage = 7,
      quality   = "common",
      slot      = "wield",
      speed     = 2.8,
      stats     = { critical = 1 },
    },
    name        = "Rusty Sword",
    roomDesc    = "Rusted Sword",
    type        = "WEAPON",
  },
  {
    behaviors   = { decay = { duration = 240 } },
    description = "A yellow, slightly moldy slice of cheese. Only a rat could find this appetizing.",
    id          = "sliceofcheese",
    keywords    = { "slice", "cheese", "moldy" },
    name        = "Slice of Cheese",
    roomDesc    = "A moldy slice of cheese",
  },
  {
    closed      = true,
    description = "Time has not been kind to this chest. It seems to be held together solely by the dirt and rust.",
    id          = "woodenchest",
    items       = {
      "limbo:rustysword",
      "limbo:leathervest",
      "limbo:potionhealth1",
      "limbo:potionstrength1",
    },
    keywords    = { "wooden", "chest" },
    maxItems    = 5,
    metadata    = { noPickup = true },
    name        = "Wooden Chest",
    roomDesc    = "A wooden chest rests in the corner, its hinges badly rusted.",
    type        = "CONTAINER",
  },
  {
    description = "Splintered, shattered, and generally destroyed remains of a training dummy",
    id          = "scraps",
    keywords    = { "dummy", "scraps" },
    metadata    = { sellable = { currency = "gold", value    = 5 } },
    name        = "Scraps",
    quality     = "poor",
    roomDesc    = "Scraps from a Training Dummy",
  },
  {
    description = "A hefty iron blade. Not the sharpest sword in the world but it will get the job done.",
    id          = "trainingsword",
    keywords    = { "sword", "training", "iron" },
    metadata    = {
      itemLevel = 10,
      level     = 5,
      maxDamage = 20,
      minDamage = 11,
      quality   = "rare",
      sellable  = { currency = "gold", value    = 30 },
      slot      = "wield",
      speed     = 2.8,
      stats     = { critical = -1, stamina  = 2, strength = 2 },
    },
    name        = "Training Sword",
    roomDesc    = "Training Sword",
    type        = "WEAPON",
  },
  {
    description = "A plain leather vest. Better than nothing.",
    id          = "leathervest",
    keywords    = { "leather", "vest" },
    metadata    = {
      itemLevel = 1,
      level     = 1,
      quality   = "common",
      sellable  = { currency = "gold", value    = 30 },
      slot      = "chest",
      stats     = { armor = 20 },
    },
    name        = "Leather Vest",
    roomDesc    = "Leather Vest",
    type        = "ARMOR",
  },
  {
    id       = "potionhealth1",
    keywords = { "potion", "health" },
    metadata = {
      level  = 1,
      usable = {
        charges           = 5,
        cooldown          = 30,
        destroyOnDepleted = true,
        options           = { restores = 30, stat     = "health" },
        spell             = "potion",
      },
    },
    name     = "Potion of Health I",
    roomDesc = "Potion of Health I",
    type     = "POTION",
  },
  {
    id       = "potionstrength1",
    keywords = { "potion", "strength" },
    metadata = {
      level  = 1,
      usable = {
        charges           = 2,
        config            = {
          description = "Increases strength by <b>10</b> for <b>15</b> seconds",
          duration    = 15000,
        },
        destroyOnDepleted = true,
        effect            = "potion.buff",
        state             = { magnitude = 10, stat      = "strength" },
      },
    },
    name     = "Potion of Strength I",
    roomDesc = "Potion of Strength I",
    type     = "POTION",
  },
  {
    description = "The blade shines a brilliant silver. Holding it you feel as if you could take on the world.",
    id          = "bladeofranvier",
    keywords    = { "sword", "blade", "ranvier" },
    metadata    = {
      itemLevel      = 15,
      level          = 10,
      maxDamage      = 26,
      minDamage      = 13,
      quality        = "epic",
      slot           = "wield",
      specialEffects = {
        "Chance on hit: Blade of Ranvier thirsts for blood and heals the wielder for 25% of damage done.",
      },
      speed          = 2.8,
      stats          = { critical = 3, stamina  = 2, strength = 2 },
    },
    name        = "Blade of Ranvier",
    roomDesc    = "Blade of Ranvier",
    script      = "ranvier-blade",
    type        = "WEAPON",
  },
  {
    description = "A rather uninteresting looking wooden shield. A rusted metal band barely hold its together and the leather arm band is nearly torn.",
    id          = "woodenshield",
    keywords    = { "shield", "wooden" },
    metadata    = {
      itemLevel = 1,
      level     = 1,
      quality   = "common",
      sellable  = { currency = "gold", value    = 30 },
      slot      = "shield",
      stats     = { armor = 10 },
    },
    name        = "Wooden Shield",
    roomDesc    = "Wooden Shield",
    type        = "ARMOR",
  },
  {
    description = "This key seems overly complex with numerous grooves.",
    id          = "test_key",
    keywords    = { "key", "odd", "oddly", "shaped" },
    metadata    = { quality = "common" },
    name        = "Oddly-shaped Key",
    roomDesc    = "A strange looking key",
  },
  {
    closed   = true,
    id       = "locked_chest",
    items    = { "limbo:rustysword" },
    keywords = { "locked", "wooden", "chest" },
    locked   = true,
    lockedBy = "limbo:test_key",
    maxItems = 5,
    metadata = { noPickup = true },
    name     = "Locked Chest",
    roomDesc = "A wooden chest rests open in the corner, its hinges badly rusted.",
    type     = "CONTAINER",
  },
}