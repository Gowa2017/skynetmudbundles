local B         = require("core.Broadcast")
local SkillFlag = require("core.SkillFlag")
local tablex    = require("pl.tablex")
local sfmt      = string.format

return {
  aliases = { "spell" },
  command = function(state)
    return function(self, args, player)
      local say   = function(message, wrapWidth)
        B.sayAt(player, message, wrapWidth)
      end;

      if not args or #args < 1 then
        return say(
                 "What skill or spell do you want to look up? Use 'skills' to view all skills/spells.");
      end

      local skill = state.SkillManager:find(args, true);
      if not skill then skill = state.SpellManager:find(args, true); end

      if not skill then return say("No such skill."); end

      say("<bold>" .. B.center(80, skill.name, "white", "-") .. "");
      if tablex.find(skill.flags, SkillFlag.PASSIVE) then
        say("<bold>Passive");
      else
        say(sfmt("<bold>Usage: %s", skill.id));
      end

      if skill.resource and skill.resource.cost then
        say(sfmt("<bold>Cost: <bold>%q %s", skill.resource.cost,
                 skill.resource.attribute));
      end

      if skill.cooldownLength then
        say(sfmt("<bold>Cooldown: <bold>%q seconds", skill.cooldownLength));
      end
      say(skill:info(player), 80);
      say("<bold>" .. B.line(80) .. "");
    end
  end,
};
