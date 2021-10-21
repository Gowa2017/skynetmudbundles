local B      = require("core.Broadcast")
local Logger = require("core.Logger")
local tablex = require("pl.tablex")

---
---A simple behavior to make an NPC aggressive. Aggressive is defined as attacking after some delay
---when a player or NPC enters the room. An aggressive NPC will only fixate their attention on one
---target at a time and not when they're already distracted by combat.
---Options:
---  delay: number, seconds after a character enters the room before attacking. Default: 5
---  warnMessage: string, Message to send to players warning them that the mob will attack soon.
---    Message supports '%name%' token to place NPC name in message. Message is sent when half of
---    the delay has passed.
---    Default '%name% growls, warning you away.'
---  attackMessage: string, Message to send to players when the mob moves to attack.
---    Message supports '%name%' token to place NPC name in message.
---    Default '%name% attacks you!'
---  towards:
---    players: boolean, whether the NPC is aggressive towards players. Default: true
---    npcs: Array<EntityReference>, list of NPC entityReferences which self NPC will attack on sight
---
---Example:
---
---    # an NPC that's aggressive towards players
---    behaviors:
---      ranvier-aggro:
---        delay: 10
---        warnMessage: '%name% snarls angrily.'
---        towards:
---          players: true
---          npcs: false
---
---    # an NPC that fights enemy NPC squirrels and rabbits
---    behaviors:
---      ranvier-aggro:
---         towards:
---           players: false
---           npcs: ["limbo:squirrel", "limbo:rabbit"]
---
return {
  listeners = {
    updateTick = function(state)
      return function(self, config)
        if not self.room then return end
        config = config and type(config) == "table" and config or {}

        -- setup default configs
        config = tablex.update({
          delay         = 5,
          warnMessage   = "%name% growls, warning you away.",
          attackMessage = "%name% attacks you!",
          towards       = { players = true, npcs    = false },
        }, config);
        if not self:isInCombat() then return end

        if self._aggroTarget then
          if self._aggroTarget.room ~= self.room then
            self._aggroTarget = nil;
            self._aggroWarned = false;
            return;
          end
          local sinceLastCheck = os.time() - self._aggroTimer
          local delayLength    = config.delay * 1000

          -- attack
          if sinceLastCheck >= delayLength then
            if not self._aggroTarget.isNpc() then
              B.sayAt(self._aggroTarget,
                      config.attackMessage:gsub("%%name%%", self.name));
            else
              Logger.verbose(
                "NPC [%q/%q] attacks NPC [%q/%q] in room %q.entityReference}.",
                self.uuid, self.entityReference, self._aggroTarget.uuid,
                self._aggroTarget.entityReference, self.room.entityReference);
            end
            self.initiateCombat(self._aggroTarget);
            self._aggroTarget = nil;
            self._aggroWarned = false;
            return;
          end

          -- warn
          if sinceLastCheck >= delayLength / 2 and not self._aggroTarget.isNpc() and
            not self._aggroWarned then
            B.sayAt(self._aggroTarget,
                    config.warnMessage:gsub("%%name%%", self.name));
            self._aggroWarned = true;
          end

          return;
        end

        -- try to find a player to be aggressive towards first
        if config.towards.players and tablex.size(self.room.players) > 0 then
          self._aggroTarget = tablex.keys(self.room.players)[1]
          self._aggroTimer = os.time()
          return;
        end

        if config.towards.npcs and tablex.size(self.room.npcs) > 0 then
          for npc, _ in pairs(self.room.npcs) do
            if npc == self then goto continue end
            if config.towards.npcs or type(config.towards.npcs) == "table" and
              tablex.find(config.towards.npcs, npc.entityReference) then
              self._aggroTarget = npc
              self._aggroTimer = os.time()
              return
            end

            ::continue::
          end
        end
      end
    end,
  },
};
