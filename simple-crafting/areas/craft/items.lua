return {
  {
    description = "An oddly bright green plant whose thorns shine as the light hits them. Perhaps you could <b><cyan>gather</cyan></b> it.",
    id          = "greenplant",
    keywords    = { "green", "plant", "resource" },
    metadata    = {
      itemLevel = 1,
      level     = 1,
      noPickup  = true,
      quality   = "common",
      resource  = {
        depletedMessage = "withers, having been stripped of usable materials.",
        materials       = { plant_material = { max = 3, min = 1 } },
      },
    },
    name        = "Green Plant",
    roomDesc    = "Green Plant",
    type        = "RESOURCE",
  },
  {
    description = "An oddly bright red rose whose thorns shine as the light hits them. Perhaps you could <b><cyan>gather</cyan></b> it.",
    id          = "redrose",
    keywords    = { "red", "rose", "resource" },
    metadata    = {
      itemLevel = 1,
      level     = 1,
      noPickup  = true,
      quality   = "uncommon",
      resource  = {
        depletedMessage = "withers, having been stripped of usable materials.",
        materials       = {
          plant_material = { max = 3, min = 2 },
          rose_petal     = { max = 2, min = 1 },
        },
      },
    },
    name        = "Red Rose",
    roomDesc    = "Red Rose",
    type        = "RESOURCE",
  },
}
