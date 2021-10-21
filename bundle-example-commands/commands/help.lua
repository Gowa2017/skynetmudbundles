local B       = require("core.Broadcast")
local Logger  = require("core.Logger")
local tablex  = require("pl.tablex")
local stringx = require("pl.stringx")

local sfmt    = string.format
local function render(state, hfile)
  local body             = hfile.body;
  local name             = hfile.name;

  local width            = 80;
  local bar              = B.line(width, "-", "yellow") .. "\r\n";

  local header           = bar .. B.center(width, name, "white") .. "\r\n" ..
                             bar;

  local formatHeaderItem = function(item, value)
    return sfmt("%s: %s\r\n\r\n", item, value)
  end;
  if (hfile.command) then
    local actualCommand = state.CommandManager:get(hfile.command);
    header = header .. formatHeaderItem("Syntax", actualCommand.usage);
    if actualCommand.aliases and #actualCommand.aliases > 0 then
      header = header ..
                 formatHeaderItem("Aliases",
                                  table.concat(actualCommand.aliases, ", "));
    end
  elseif hfile.channel then
    header = header ..
               formatHeaderItem("Syntax",
                                state.ChannelManager:get(hfile.channel)
                                  :getUsage());
  end

  local footer           = bar;
  if hfile.related and #hfile.related > 0 then
    footer = B.center(width, "RELATED", "yellow", "-") .. "\r\n";
    local related = table.concat(hfile.related, ", ")
    footer = footer .. B.center(width, related) .. "\r\n";
    footer = footer .. bar;
  end

  return header .. B.wrap(hfile.body, 80) .. footer;
end

local function searchHelpfiles(args, player, state)
  args = table.concat(stringx.split(args, " "), " ", 2)
  if not args or #args < 1 then
    -- "help search" syntax is included in "help help"
    return state.CommandManager:get("help"):execute("help", player);
  end

  local results = state.HelpManager:find(args);
  if not results or tablex.size(results) < 1 then
    return B.sayAt(player, "Sorry, no results were found for your search.");
  end
  if tablex.size(results) == 1 then
    local hfile = tablex.values(results)[1].hfile
    return B.sayAt(player, render(state, hfile));
  end
  B.sayAt(player,
          "<yellow>---------------------------------------------------------------------------------");
  B.sayAt(player, "<white>Search Results:");
  B.sayAt(player,
          "<yellow>---------------------------------------------------------------------------------");

  for name, help in pairs(results) do B.sayAt(player, "<cyan>" .. name); end
end

return {
  usage   = "help [search] [topic keyword]",
  command = function(state)
    return function(self, args, player)
      if not args or #args < 2 then
        -- look at "help help" if they haven't specified a file
        return state.CommandManager:get("help"):execute("help", player);
      end

      -- "help search"
      if args:find("search") == 1 then
        return searchHelpfiles(args, player, state);
      end

      local hfile   = state.HelpManager:get(args);

      if not hfile then
        Logger.error(sfmt("MISSING-HELP: [%s]", args));
        return
          B.sayAt(player, "Sorry, I couldn't find an entry for that topic.");
      end
      local ok, err = xpcall(function()
        B.sayAt(player, render(state, hfile))
      end, debug.traceback)
      if not ok then
        Logger.warn(sfmt("UNRENDERABLE-HELP: [%s]", args));
        Logger.warn(err);
        B.sayAt(player, sfmt("Invalid help file for %s.", args));
      end
    end
  end,
};
