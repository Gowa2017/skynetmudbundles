return {
  listeners = {
    playerEnter = function(state)
      return function(self, player)
        if self:hasEffectType("speaking") then return end

        local speak = state.EffectFactory:create("speak", {}, {
          messageList = {
            "Welcome, %player%. The combat training area lies to the east.",
            "To the west lies Wally's shop where you can stock up on potions.",
          },
          outputFn    = function(message)
            message = message:gsub("%%player%%", player.name);
            state.ChannelManager:get("say"):send(state, self, message);
          end,
        });
        self:addEffect(speak);
      end
    end,

    playerLeave = function(state)
      return function(self, layer)
        local speaking = self.effects:getByType("speaking");
        if speaking then speaking:remove() end
      end
    end,
  },
};
