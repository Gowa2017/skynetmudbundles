local wrapper       = require("core.lib.wrapper")
local stringx       = require("pl.stringx")
local tablex        = require("pl.tablex")

local B             = require("core.Broadcast")
local CommandType   = require("core.CommandType")
local Logger        = require("core.Logger")
local PlayerRoles   = require("core.PlayerRoles")
local Room          = require("core.Room")
local wrapper       = require("core.lib.wrapper")

local ChannelErrors = require("core.ChannelErrors")
local CommandParser = wrapper.loadBundleScript("lib/CommandParser",
                                               "bundle-example-lib")
local CommandErrors = wrapper.loadBundleScript("lib/CommandErrors",
                                               "bundle-example-lib")

-- local   CommandParser, InvalidCommandError, RestrictedCommandError  = require('../../bundle-example-lib/lib/CommandParser');

return {
  event = function(state)
    return function(self, player)
      player.socket:once("data", function(data)
        local function loop() player.socket:emit("commands", player); end
        data = wrapper.trim(data)

        if not data or #data < 1 then return loop() end

        player._lastCommandTime = os.time()
        local ok, err = xpcall(function()
          -- allow for modal commands, _commandState is set below when command.execute() returns a value
          if player._commandState then
            local commandState, command = player._commandState.state,
                                          player._commandState.command
            -- const { state: commandState, command } = player._commandState;
            -- note this calls command.func(), not command.execute()
            local newState              =
              command:func(data, player, command.name, commandState);
            if newState then
              player._commandState.state = newState;
            else
              player._commandState = nil;
              B.prompt(player);
            end
            loop();
            return true;
          end
          local result = CommandParser.parse(state, data, player);
          if not result then error("parse error") end
          if result.type == CommandType.MOVEMENT then
            player:emit("move", result)
          elseif result.type == CommandType.COMMAND then
            local requiredRole = result.command.requiredRole or
                                   PlayerRoles.PLAYER
            if requiredRole > player.role then
              error(CommandErrors.RestrictedCommandError)
            end
            -- commands have no lag and are not queued, just immediately execute them
            local state        = result.command:execute(result.args, player,
                                                        result.originalCommand);
            if state then
              player._commandState = { command = result.command,
              state   = state }
              loop()
              return true
            end
            player._commandState = nil
          elseif result.type == CommandType.CHANNEL then
            local channel = result.channel
            if channel.minRequiredRole and channel.minRequiredRole > player.role then
              error(CommandErrors.RestrictedCommandError)
            end
            local ok, err = pcall(function()
              channel:send(state, player, result.args)
            end)
            if not ok then
              if err == ChannelErrors.NoPartyError then
                B.sayAt(player, "You aren't ina group")
              elseif err == ChannelErrors.NoRecipientError then
                B.sayAt(player, "send the message to whom?")
              elseif err == ChannelErrors.NoMessageError then
                B.sayAt(player, string.format("\r\nChannel: %q", channel.name))
                B.sayAt(player, string.format("Syntax: %q", channel:getUsage()))
                if channel.description then
                  B.sayAt(player, channel.description)
                end
              end
            end
          elseif result.type == CommandType.SKILL then
            player:queueCommand({
              execute = function()
                player:emit("useAbility", result.skill, result.args)
              end,
              label   = data,
            }, result.skill.lag or state.Config.get("skilllag") or 1000)
          end
        end, debug.traceback)

        --- call is not ok
        if not ok then
          if err == CommandErrors.InvalidCommandError then
            -- check to see if room has a matching context-specific command
            local isRoomCommand = false
            if player.room and Room:class_of(player.room) then
              local roomCommands = player.room:getMeta("commands")
              local command      = stringx.split(data, " ")
              if roomCommands and tablex.find(roomCommands, command[1]) then
                player.room:emit("command", player, command[1],
                                 table.concat(command, " ", 2))
                isRoomCommand = true
              end
            end
            if not isRoomCommand then
              B.sayAt(player, "Huh?");
              Logger.warn("WARNING: Player tried non-existent command '%q'",
                          data);
            end
          elseif err == CommandErrors.RestrictedCommandError then
            B.sayAt(player, "You can't do that.")
          else
            Logger.error(tostring(err))
          end
          B.prompt(player);
          loop();
        end

        --- command execute succes, err now is a tag use to notify us whehter to loopit.
        if ok and not err then
          B.prompt(player);
          loop();
        end
      end);
    end
  end,
};
