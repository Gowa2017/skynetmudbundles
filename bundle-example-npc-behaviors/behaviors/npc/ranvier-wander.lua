local Broadcast = require("core.Broadcast")
local Logger    = require("core.Logger")
local tablex    = require("pl.tablex")
local sfmt      = string.format

---
---An example behavior that causes an NPC to wander around an area when not in combat
---Options:
---  areaRestricted: boolean, true to restrict the NPC's wandering to his home area. Default: false
---  restrictTo: Array<EntityReference>, list of room entity references to restrict the NPC to. For
---    example if you want them to wander along a set path
---  interval: number, delay in seconds between room movements. Default: 20
---
return {
  listeners = {
    updateTick = function(state)
      return function(self, config)
        if self:isInCombat() or not self.room then return end
        config = config or {}

        config = tablex.update({
          areaRestricted = false,
          restrictTo     = nil,
          interval       = 20,
        }, config);
        if not self._lastWanderTime then self._lastWanderTime = os.time() end
        if os.time() - self._lastWanderTime < config.interval * 1000 then

          return
        end

        self._lastWanderTime = os.time()
        local exits      = self.room:getExits()
        if #exits < 1 then return end

        local roomExit   = exits[math.random(#exits)]
        local randomRoom = state.RoomManager:getRoom(roomExit.roomId)
        local door       = self.room:getDoor(randomRoom) or
                             (randomRoom and randomRoom:getDoor(self.room))
        if randomRoom and door and (door.locked or door.closed) then
          Logger.verbose("NPC [%q] wander blocked by door", self.uuid)
        end
        if not randomRoom or (config.restrictTo and
          not tablex.find(config.restrictTo, randomRoom.entityReference)) or
          (config.areaRestricted and randomRoom.area ~= self.area) then

          return
        end

        Logger.verbose("NPC [%q] wandering from %q to %q.", self.uuid,
                       self.room.entityReference, randomRoom.entityReference);
        Broadcast.sayAt(self.room,
                        sfmt("%q wanders %q}.", self.name, roomExit.direction));
        self:moveTo(randomRoom);
      end
    end,
  },
};
