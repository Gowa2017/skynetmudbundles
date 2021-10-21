local EventUtil = require("core.EventUtil")
local Logger    = require("core.Logger")
local tablex    = require("pl.tablex")
local sfmt      = string.format

local wrapper   = require("core.lib.wrapper")

---
---Delete character event
---
return {
  event = function(state)
    return function(self, socket, args)
      local account    = args.account;
      local say        = EventUtil.genSay(socket);
      local write      = EventUtil.genWrite(socket);

      say("\r\n------------------------------");
      say("|      Delete a Character");
      say("------------------------------");

      local characters = {}
      for charName, char in pairs(account.characters) do
        if char.deleted == false then characters[#characters + 1] = char end
      end

      local options    = {}
      tablex.foreachi(characters, function(char)
        options[#options + 1] = {
          display  = sfmt("Delete <bold>%q", char.username),
          onSelect = function()
            write(sfmt(
                    "<bold>Are you sure you want to delete <bold>%q? <cyan>[Y/n] ",
                    char.username));
            socket:once("data", function(confirmation)
              say("");
              confirmation = wrapper.trim(confirmation):lower()

              if not confirmation:match("[yn]") then
                say("<bold>Invalid Option");
                return socket:emit("choose-character", socket, args);
              end

              if confirmation == "n" then
                say("No one was deleted...");
                return socket:emit("choose-character", socket, args);
              end

              say(sfmt("Deleting %q", char.username));
              account:deleteCharacter(char.username);
              say("Character deleted.");
              return socket:emit("choose-character", socket, args);
            end);
          end,

        }

      end)

      options[#options + 1] = { display = "" };

      options[#options + 1] = {
        display  = "Go back to main menu",
        onSelect = function()
          socket:emit("choose-character", socket, args);
        end,
      };

      local optionI    = 1;
      for i, opt in ipairs(options) do
        if opt.onSelect then
          say(sfmt("| <cyan>[%q] %q", optionI, opt.display));
          optionI = optionI + 1
        else
          say(sfmt("| <bold>%q", opt.display));
        end
      end
      socket:write("|\r\n\"-> ");

      socket:once("data", function(choice)
        choice = tonumber(choice)
        if not choice then
          return socket:emit("choose-character", socket, args);
        end

        local selection = tablex.filter(options,
                                        function(o) return o.onSelect end)[choice];

        if selection then
          Logger.log("Selected " .. selection.display);
          return selection:onSelect();
        end

        return socket:emit("choose-character", socket, args);
      end);
    end
  end,
};
