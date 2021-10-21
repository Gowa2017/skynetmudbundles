local Broadcast = require("core.Broadcast")
local Logger    = require("core.Logger")
local sfmt      = string.format

return {
  listeners = {
    updateTick = function(state)
      return function(self, config)
        local now      = os.time()
        local duration = config and config.duration or 60
        duration = duration * 1000
        self.decaysAt = self.decaysAt or now + duration
        if now >= self.decaysAt then
          self:emit("decay")
        else
          self.timeUntilDecay = self.decaysAt - now
        end

      end
    end,
    decay      = function(state)
      return function(self, config)
        local now      = os.time()
        local duration = config and config.duration or 60
        duration = duration * 1000
        self.decaysAt = self.decaysAt or now + duration
        if now >= self.decaysAt then
          self:emit("decay")
        else
          local room, belongsTo = self.room, self.belongsTo
          if belongsTo then
            local owner = self:findOwner()
            if owner then
              Broadcast.sayAt(owner, sfmt("You %q has rotted away!", self.name))
            end
          end
          if room then
            Broadcast.sayAt(room, sfmt("%q has rotted away!", self.name));
          end
          Logger.verbose("%q has decayed", self.id)
          state.ItemManager:remove(self)
        end
      end
    end,
  },
}
