local CommandType   = require("core.CommandType")
local Room          = require("core.Room")
local Logger        = require("core.Logger")

local stringx       = require("pl.stringx")
local tablex        = require("pl.tablex")
local wrapper       = require("core.lib.wrapper")
local CommandErrors = wrapper.loadBundleScript("lib/CommandErrors",
                                               "bundle-example-lib")

---Interpreter.. you guessed it, interprets command input
---@class  CommandParser
local M             = {}

---
---Parse a given string to find the resulting command/arguments
---@param state GameState state
---@param data string data
---@param player Player player
---@return table #{{
---  type: CommandType,
---  command: Command,
---  skill: Skill,
---  channel: Channel,
---  args: string,
---  originalCommand: string
---}}
---
function M.parse(state, data, player)
  data = wrapper.trim(data)
  local parts         = stringx.split(data, " ")
  local command       = parts[1]:lower()

  if not #command or #command < 1 then error(CommandErrors.InvalidCommandError) end

  local args          = table.concat(parts, " ", 2)

  --- Kludge so that 'l' alone will always force a look,
  --- instead of mixing it up with lock or list.
  --- TODO: replace this a priority list
  if command == "l" then
    return {
      type    = CommandType.COMMAND,
      command = state.CommandManager:get("look"),
      args    = args,
    };
  end

  -- Same with 'i' and inventory.
  if command == "i" then
    return {
      type    = CommandType.COMMAND,
      command = state.CommandManager:get("inventory"),
      args    = args,
    };
  end

  -- see if they matched a direction for a movement command
  local roomDirection = M.checkMovement(player, command);

  if roomDirection then
    local roomExit = M.canGo(player, roomDirection)
    return {
      type            = CommandType.MOVEMENT,
      args            = args,
      originalCommand = command,
      roomExit        = roomExit,
    };
  end

  -- see if they matched exactly a command
  if state.CommandManager:get(command) then
    return {
      type            = CommandType.COMMAND,
      command         = state.CommandManager:get(command),
      args            = args,
      originalCommand = command,
    };
  end

  -- see if they typed at least the beginning of a command and try to match
  local found         = state.CommandManager:find(command, true) -- return Alias;
  if found then
    return {
      type            = CommandType.COMMAND,
      command         = found.command,
      args            = args,
      originalCommand = found.alias,
    };
  end

  -- check channels
  found = state.ChannelManager:find(command);
  if found then
    return { type    = CommandType.CHANNEL, channel = found, args    = args };
  end

  -- finally check skills
  found = state.SkillManager:find(command);
  if found then
    return { type  = CommandType.SKILL, skill = found, args  = args };
  end

  error(CommandErrors.InvalidCommandError)
end

---
---Check command for partial match on primary directions, or exact match on secondary name or abbreviation
---@param player Player player
---@param command string command
---@return string | nil
function M.checkMovement(player, command)

  if not player.room or not Room:class_of(player.room) then return end

  local primaryDirections   = { "north", "south", "east", "west", "up", "down" };
  for _, direction in pairs(primaryDirections) do
    if direction:find(command) == 1 then return direction end
  end

  local secondaryDirections = {
    { abbr = "ne", name = "northeast" },
    { abbr = "nw", name = "northwest" },
    { abbr = "se", name = "southeast" },
    { abbr = "sw", name = "southwest" },
  };

  for _, direction in ipairs(secondaryDirections) do
    if direction.abbr == command or direction.name:find(command) == 1 then
      return direction.name
    end
  end

  local _, otherExit        = tablex.find_if(player.room:getExits(), function(
    roomExit
  ) return roomExit.direction == command and roomExit or false end)
  return otherExit and otherExit.direction or nil;
end

--[[*
   * Determine if a player can leave the current room to a given direction
   * @param {Player} player
   * @param {string} direction
   * @return {boolean}
   --]]
function M.canGo(player, direction)
  if not player.room then return false end
  local _, roomexit = tablex.find_if(player.room:getExits(), function(roomExit)
    return roomExit.direction == direction and roomExit or false
  end)
  return roomexit or false
end

return M
