local B       = require("core.Broadcast")
local stringx = require("pl.stringx")
local tablex  = require("pl.tablex")
local sfmt    = string.format

return {
  usage   = "config {set/list} [setting] [value]",
  aliases = { "toggle", "options", "set" },
  command = function(state)
    return function(self, args, player)
      if not args or #args < 1 then
        B.sayAt(player, "Configure what?");
        return state.CommandManager:get("help"):execute("config", player);
      end

      local possibleCommands                 = { "set", "list" };
      local command, configToSet, valueToSet
      local argList                          = stringx.split(args, " ")
      command = #argList < 1 and args or argList[1]
      configToSet = #argList > 1 and argList[2]
      valueToSet = #argList > 2 and argList[3]

      if not tablex.find(possibleCommands, command) then
        B.sayAt(player, sfmt("<red>Invalid config command: %q", command));
        return state.CommandManager:get("help"):execute("config", player);
      end

      if command == "list" then
        B.sayAt(player, "Current Settings:");
        for key, val in pairs(player.metadata.config or {}) do
          var = var and "on" or "off"
          B.sayAt(player, sfmt("  %s: %s", key, val));
        end
        return;
      end

      if not configToSet then
        B.sayAt(player, "Set what?");
        return state.CommandManager:get("help"):execute("config", player);
      end

      local possibleSettings                 =
        { "brief", "autoloot", "minimap" };

      if not tablex.find(possibleSettings, configToSet) then
        B.sayAt(player,
                sfmt("<red>Invalid setting: %q. Possible settings: %q",
                     configToSet, table.concat(possibleCommands, " ")));
        return state.CommandManager.get("help").execute("config", player);
      end

      if not valueToSet then
        B.sayAt(player,
                sfmt("<red>What value do you want to set for %q?", configToSet));
        return state.CommandManager:get("help"):execute("config", player);
      end

      local possibleValues                   = { on  = true, off = false };

      if possibleValues[valueToSet] == nil then
        return B.sayAt(player, "<red>Value must be either: on / off");
      end

      if not player:getMeta("config") then player:setMeta("config", {}); end

      player:setMeta(sfmt("config.%q", configToSet), possibleValues[valueToSet]);

      B.sayAt(player, "Configuration value saved");
    end
  end,
};
