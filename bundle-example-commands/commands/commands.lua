local sprintf   = string.format
local Broadcast = require("core.Broadcast")
local tablex    = require("pl.tablex")

local function sayAtColumns(source, strings, numCols)
  -- Build a 2D map of strings by col/row
  local col             = 1;
  local perCol          = math.ceil(#strings / numCols);
  local rowCount        = 0;
  local colWidth        = math.floor((3 * 20) / numCols);
  local columnedStrings = tablex.reduce(function(map, string)
    if rowCount >= perCol then
      rowCount = 0;
      col = col + 1;
    end
    map[col] = map[col] or {};
    map[col][#map[col] + 1] = string
    rowCount = rowCount + 1
    return map;
  end, strings, {})

  col = 1;
  local row             = 1;
  local said, n         = 1, #strings;
  while said < n do
    if columnedStrings[col] and columnedStrings[col][row] then
      local string = columnedStrings[col][row];
      said = said + 1
      Broadcast.at(source, sprintf("%-" .. colWidth .. "s", string));
    end
    col = col + 1;
    if col == numCols then
      Broadcast.sayAt(source);
      col = 1;
      row = row + 1;
    end
  end
  -- append another line if need be
  if (col % numCols) ~= 0 then Broadcast.sayAt(source); end
end

return {
  aliases = { "channels" },
  command = function(state)
    return function(self, args, player)

      -- print standard commands
      Broadcast.sayAt(player, "<bold><white>                  Commands");
      Broadcast.sayAt(player,
                      "<bold><white>===============================================");

      local commands        = {};
      for name, command in pairs(state.CommandManager.commands) do
        if player.role >= command.requiredRole then
          commands[#commands + 1] = name
        end
      end

      -- commands.sort()
      sayAtColumns(player, commands, 4)

      -- channels
      Broadcast.sayAt(player);
      Broadcast.sayAt(player, "<bold><white>                  Channels");
      Broadcast.sayAt(player,
                      "<bold><white>===============================================");

      local i               = 0;
      local channelCommands = {};
      for name, _ in pairs(state.ChannelManager.channels) do
        channelCommands[#channelCommands + 1] = name
      end
      -- channelCommands.sort();
      sayAtColumns(player, channelCommands, 4)

      -- end with a line break
      Broadcast.sayAt(player, "");
    end
  end,
};
