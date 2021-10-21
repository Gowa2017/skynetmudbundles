local wrapper      = require("core.lib.wrapper")

local Logger       = require("core.Logger")
local Telnet       = require("core.Telnet")

local TelnetStream = wrapper.loadBundleScript("lib/TelnetStream")

return {
  listeners = {
    startup  = function(state)
      return function(self, commander)
        ---Effectively the 'main' game loop but not really because it's a REPL
        ---@type TelnetServer
        local server = Telnet.TelnetServer(function(rawSocket)
          ---@type TelnetSocket
          local telnetSocket = Telnet.TelnetSocket();
          telnetSocket:attach(rawSocket);
          telnetSocket:telnetCommand(Telnet.Sequences.WILL,
                                     Telnet.Options.OPT_EOR);

          ---@type TelnetStream
          local stream       = TelnetStream();
          stream:attach(telnetSocket);

          stream:on("interrupt", function()
            stream.write("\n*interrupt*\n");
          end);

          stream:on("error", function(err)
            if err.errno == "EPIPE" then
              return Logger.error(
                       "EPIPE on write. A websocket client probably connected to the telnet port.");
            end
            Logger.error(err);
          end);

          -- Register all of the input events (login, etc.)
          state.InputEventManager:attach(stream);
          stream:write("Connecting...");
          Logger.log("User connected...");
          stream:emit("intro", stream);
          stream:resume()
        end).netServer;

        -- Start the server and setup error handlers.
        server:listen("localhost", commander.port):on("error", function(err)
          if err.code == "EADDRINUSE" then
            Logger.error(
              "Cannot start server on port ${commander.port}, address is already in use.");
            Logger.error("Do you have a MUD server already running?");
          elseif err.code == "EACCES" then
            Logger.error(
              "Cannot start server on port ${commander.port}: permission denied.");
            Logger.error(
              "Are you trying to start it on a priviledged port without being root?");
          else
            Logger.error("Failed to start MUD server:");
            Logger.error(err);
          end

        end);
        Logger.info("Telnet server started on port: %q...", commander.port);
      end
    end,

    shutdown = function(state) return function() end end,
  },
};
