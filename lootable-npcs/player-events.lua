local B = require("core.Broadcast")

return {
  listeners = {
    currency = function(state)
      return function(self, currency, amount)
        local friendlyName = currency:gsub("_", " "):gsub("%b%w", function(l)
          return l:upper()
        end)
        local key          = "currencies." .. currency
        if not self:getMeta("currencies") then
          self:setMeta("currencies", {})
        end
        self:setMeta(key, (self:getMeta(key) or 0) + amount)
        self:save()
        B.sayAt(self,
                string.format(
                  "<green>You receive currency: <b><white>[%q] x%q.",
                  friendlyName, amount));

      end
    end,
  },
}
