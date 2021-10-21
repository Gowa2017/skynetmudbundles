local wrapper      = require("core.lib.wrapper")

local Combat       = wrapper.loadBundleScript("lib/Combat");
local CombatErrors = wrapper.loadBundleScript("lib/CombatErrors");
local B            = require("core.Broadcast")
local Logger       = require("core.Logger")

return {
  usage   = "consider <target>",
  command = function(state)
    return function(self, args, player)
      if not args or #args < 1 then
        return B.sayAt(player, "Who do you want to size up for a fight?");
      end
      local target     
      local ok, e       = xpcall(function()
        target = Combat.findCombatant(player, args)
      end, debug.traceback)
      if not ok then
        if e == CombatErrors.CombatSelfError or e ==
          CombatErrors.CombatNonPvpError or e ==
          CombatErrors.CombatInvalidTargetError or e ==
          CombatErrors.CombatPacifistError then
          return B.sayAt(player, tostring(e))
        end
        Logger.error(e)
      end
      if not target then return B.sayAt(player, "They aren't here."); end

      local description = "";
      local levelDiff   = player.level - target.level
      if levelDiff > 4 then
        description =
          "They are much weaker than you. You would have no trouble dealing with a few of them at once.";
      elseif levelDiff > 9 then
        description =
          "They are <b>much</b> stronger than you. They will kill you and it will hurt the whole time you're dying.";
      elseif levelDiff > 5 then
        description =
          "They are quite a bit more powerful than you. You would need to get lucky to defeat them.";
      elseif levelDiff > 3 then
        description =
          "They are a bit stronger than you. You may survive but it would be hard won.";
      else
        description =
          "You are nearly evenly matched. You should be wary fighting more than one at a time.";
      end

      B.sayAt(player, description);
    end
  end,
};
