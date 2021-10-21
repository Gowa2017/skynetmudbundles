local wrapper   = require("core.lib.wrapper")
local sprintf   = string.format

local B         = require("core.Broadcast")
local Config    = require("core.Config")
local Logger    = require("core.Logger")

local LevelUtil =
  wrapper.loadBundleScript("lib/LevelUtil", "bundle-example-lib");

return {
  listeners = {
    ---
    ---Handle a player movement command. From: 'commands' input event.
    ---movementCommand is a result of CommandParser.parse
    move          = function(state)
      return function(self, movementCommand)
        local roomExit = movementCommand.roomExit

        if not roomExit then
          return B.sayAt(self, "You can't go that way!");
        end

        if self:isInCombat() then
          return B.sayAt(self, "You are in the middle of a fight!");
        end
        local nextRoom = state.RoomManager:getRoom(roomExit.roomId)
        local oldRoom  = self.room
        local door     = oldRoom:getDoor(nextRoom) or nextRoom:getDoor(oldRoom)
        if door then
          if door.locked then
            return B.sayAt(self, "The door is locked.");
          end

          if door.closed then
            return B.sayAt(self, "The door is closed.");
          end
        end

        self:moveTo(nextRoom, function()
          state.CommandManager:get("look"):execute("", self);
        end);

        B.sayAt(oldRoom, sprintf("%s leaves.", self.name));
        B.sayAtExcept(nextRoom, sprintf("%s enters.", self.name), self);

        for follower, _ in pairs(self.followers) do
          if follower.room ~= oldRoom then goto continue end
          if follower:isNpc() then
            follower:moveTo(nextRoom)
          else
            B.sayAt(follower, sprintf("\r\nYou follow %s to %s.title}.",
                                      self.name, nextRoom.title));
            follower.emit("move", movementCommand);

          end
          ::continue::
        end
      end
    end,

    save          = function(state)
      return function(self, callback)
        state.PlayerManager:save(self);
        if type(callback) == "function" then callback() end
      end
    end,

    commandQueued = function(state)
      return function(self, commandIndex)
        local command = self.commandQueue:queue()[commandIndex];
        local ttr     = sprintf("%.1f",
                                self.commandQueue:getTimeTilRun(commandIndex));
        B.sayAt(self, sprintf(
                  "<bold><yellow>Executing <white>%s</white> <yellow>in <white>%q <yellow>seconds.",
                  command.label, ttr));
      end
    end,

    updateTick    = function(state)
      return function(self)
        if self.commandQueue:hasPending() and self.commandQueue:lagRemaining() <=
          0 then
          B.sayAt(self);
          self.commandQueue:execute();
          B.prompt(self);
        end
        local lastCommandTime      = self._lastCommandTime or math.maxinteger
        local timeSinceLastCommand = os.time() - lastCommandTime;
        local maxIdleTime          = (math.abs(Config.get("maxIdleTime")) *
                                       60000) or math.maxinteger

        if timeSinceLastCommand > maxIdleTime and not self:isInCombat() then
          self.save(function()
            B.sayAt(self,
                    sprintf(
                      "You were kicked for being idle for more than %q 60000} minutes!",
                      maxIdleTime / 6000));
            B.sayAtExcept(self.room, sprintf("%s disappears.", self.name), self);
            Logger.log("Kicked %s for being idle.", self.name);
            state.PlayerManager:removePlayer(self, true);
          end);
        end
      end
    end,

    --
    -- Handle player gaining experience
    -- @param {number} amount Exp gained
    --
    experience    = function(state)
      return function(self, amount)
        B.sayAt(self,
                sprintf("<blue>You gained <bold>%q experience!</blue>", amount));

        local totalTnl = LevelUtil.expToLevel(self.level + 1);

        -- level up, currently wraps experience if they gain more than needed for multiple levels
        if self.experience + amount > totalTnl then
          B.sayAt(self,
                  "                                   <bold><blue>!Level Up!");
          B.sayAt(self, B.progress(80, 100, "blue"));

          local nextTnl = totalTnl;
          while self.experience + amount > nextTnl do
            amount = (self.experience + amount) - nextTnl;
            self.level = self.level + 1;
            self.experience = 0;
            nextTnl = LevelUtil.expToLevel(self.level + 1);
            B.sayAt(self,
                    sprintf("<blue>You are now level <bold>%q>!>", self.level));
            self.emit("level");
          end
        end
        self.experience = self.experience + amount;
        self:save();
      end
    end,
  },
};
