return {
  listeners = {
    ---
    equip = function(state)
      ---Handle a player equipping an item with a `stats` property
      ---@param slot string string slot
      ---@param item Item item
      return function(self, slot, item)
        if not item.metadata.stats then return end

        local config      =
          { name = "Equip: " .. slot, type = "equip." .. slot };

        local effectState = { slot  = slot, stats = item.metadata.stats };

        self:addEffect(state.EffectFactory:create("equip", config, effectState));
      end
    end,
  },
};
