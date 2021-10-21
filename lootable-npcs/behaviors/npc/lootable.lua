local LootTable = loadfile("bundles/lootable-npcs/lib/LootTable.lua")()

local Player    = require("core.Player")
local Item      = require("core.Item")
local Logger    = require("core.Logger")

local tablex    = require("pl.tablex")
local sfmt      = string.format

return {
  listeners = {
    killed = function(state)
      return function(self, config, killer)
        local room, name, area, keywords = self.room, self.name, self.area,
                                           self.keywords
        local lootTable                  = LootTable(state, config)
        local currencies                 = lootTable:currencies()
        local roll                       = lootTable:roll()
        local items                      =
          tablex.imap(function(item)
            return state.ItemFactory:create(
                     state.AreaManager:getAreaByReference(item), item)
          end, roll)
        ---@type Item
        local corpse                     = Item(area, {
          id        = "corpse",
          name      = sfmt("Corpse of %q", name),
          roomDesc  = sfmt("The rotting corpse of %q", name),
          keywords  = { "corpse" },
          type      = "Container",
          metadata  = { noPickup = true },
          maxItems  = #items,
          behaviors = { decay = { duration = 100 } },
        })
        corpse:hydrate(state)
        Logger.log("Generated corpse: %q", corpse.uuid);
        for _, item in ipairs(items) do
          item:hydrate(state)
          corpse:addItem(item)
        end
        room:addItem(corpse)
        state.ItemManager:add(corpse)
        if killer and Player:class_of(killer) then
          if currencies then
            local recipients
            if not killer.party then
              recipients = { killer }
            else
              recipients = {}
              for partyer, _ in ipairs(killer.party) do
                if partyer.room == killer.room then
                  recipients[#recipients + 1] = partyer
                end
              end
            end
            for _, currency in ipairs(currencies) do
              local remaining = currency.amount
              -- Split currently evenly amount recipients.  The way the math works out the leader
              -- of the party will get any remainder if the currency isn't divisible evenly
              for _, recipient in ipairs(recipients) do
                local amount = math.floor(remaining / #recipients) + remaining %
                                 #recipients
                remaining = remaining - amount
                recipient:emit("currency", currency.name, amount)
                state.CommandManager:get("look"):execute(corpse.uuid, recipient)
              end
            end
          end
        end
      end
    end,
  },
}
