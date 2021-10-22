local Broadcast = require("core.Broadcast")
local Config    = require("core.Config")
local EventUtil = require("core.EventUtil")
local Logger    = require("core.Logger")
local tablex    = require("pl.tablex")
local wrapper   = require("core.lib.wrapper")

return {
  event = function(state)
    return function(self, socket, args)
      local account         = args.account;

      local say             = EventUtil.genSay(socket);
      local write           = EventUtil.genWrite(socket);
      local pm              = state.PlayerManager;

      ---
      ---Player selection menu:
      ---Can select existing player
      ---Can create new (if less than 3 living chars)
      ---
      say("\r\n------------------------------");
      say("|      Choose your fate");
      say("------------------------------");

      -- This just gets their names.

      local characters      = {}
      for _, char in pairs(account.characters) do
        if not char.deleted then characters[#characters + 1] = char end
      end
      local maxCharacters   = Config.get("maxCharacters");
      local canAddCharacter = #characters < maxCharacters;

      local options         = {};

      -- Configure account options menu
      options[#options + 1] = {
        display  = "Change Password",
        onSelect = function()
          socket:emit("change-password", socket,
                      { account   = account, nextStage = "choose-character" });
        end,
      };

      if canAddCharacter then
        options[#options + 1] = {
          display  = "Create New Character",
          onSelect = function()
            socket:emit("create-player", socket, { account = account });
          end,
        };
      end
      if #characters > 0 then
        options[#options + 1] = { display = "Login As:" }
        tablex.foreach(characters, function(char, _)
          options[#options + 1] = {
            display  = char.username,
            onSelect = function()
              local currentPlayer = pm:getPlayer(char.username)
              local exist         = false
              if currentPlayer then
                -- kill old connection
                Broadcast.at(currentPlayer,
                             "Connection taken over by another client. Goodbye.");
                currentPlayer.socket:stop();

                -- link new socket
                currentPlayer.socket = socket;
                Broadcast.at(currentPlayer,
                             "Taking over old connection. Welcome.");
                Broadcast.prompt(currentPlayer);

                currentPlayer.socket:emit("commands", currentPlayer);
                return;
              end
              currentPlayer = state.PlayerManager:loadPlayer(state, account,
                                                             char.username);
              currentPlayer.socket = socket;
              socket:emit("done", socket, { player = currentPlayer });
            end,
          }

        end)
      end

      options[#options + 1] = { display = "" }
      if #characters > 0 then
        options[#options + 1] = {
          display  = "Delete a Character",
          onSelect = function()
            socket:emit("delete-character", socket, args);
          end,
        };
      end

      -- Display options menu
      options[#options + 1] = {
        display  = "Delete This Account",
        onSelect = function()
          say(
            "<bold>By deleting this account, all the characters will be also deleted.");
          write(
            "<bold>Are you sure you want to delete this account? <cyan>[Y/n] ");
          socket:once("data", function(confirmation)
            say("");
            confirmation = wrapper.trim(confirmation):lower()
            if not confirmation:find("[yn]") then
              say("<bold>Invalid Option");
              return socket:emit("choose-character", socket, args);
            end

            if confirmation == "n" then
              say("No one was deleted...");
              return socket:emit("choose-character", socket, args);
            end

            say(string.format("Deleting account <bold>%q", account.username));
            account:deleteAccount();
            say("Account deleted, it was a pleasure doing business with you.");
            socket:stop();
          end);
        end,
      };

      options[#options + 1] = {
        display  = "Quit",
        onSelect = function() socket:stop() end,
      };

      local optionI         = 0;
      tablex.foreach(options, function(opt, _)
        if opt.onSelect then
          optionI = optionI + 1;
          say(string.format("| <cyan>[%q] %q", optionI, opt.display));
        else
          say(string.format("| <bold>%q", opt.display));
        end
      end)

      socket:write("|\r\n-> ");

      socket:once("data", function(choice)
        choice = tonumber(choice)
        if not choice then
          return socket:emit("choose-character", socket, args);
        end

        local selection = tablex.filter(options,
                                        function(o, _) return o.onSelect end)[choice]
        -- local selection = options.filter(o => !!o.onSelect)[choice];

        if selection then
          Logger.log("Selected " .. selection.display);
          return selection.onSelect();
        end

        return socket:emit("choose-character", socket, args);
      end);

    end
  end,
};
