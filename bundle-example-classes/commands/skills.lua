local sprintf = string.format
local B       = require("core.Broadcast")
local Logger  = require("core.Logger")

return {
  aliases = { "abilities", "spells" },
  command = function(state)
    return function(self, args, player)
      local say = function(message) B.sayAt(player, message) end;
      say("<bold>" .. B.center(80, "Abilities", "green"));
      say("<bold>" .. B.line(80, "=", "green"));

      for level, abilities in pairs(player.playerClass:abilityTable()) do
        abilities.skills = abilities.skills or {};
        abilities.spells = abilities.spells or {};
        if #abilities.skills < 1 and #abilities.spells < 1 then
          goto continue
        end
        say(sprintf("\r\n<bold>Level %q", level));
        say(B.line(50));
        local i = 0;

        if #abilities.skills > 0 then say("\r\n<bold>Skills"); end
        for _, skillId in ipairs(abilities.skills) do
          local skill = state.SkillManager:get(skillId);
          if not skill then
            Logger.error(sprintf("Invalid skill in ability table: %q:%q:%q",
                                 player.PlayerClass.name, level, skillId));
            goto nextcontinue
          end
          local name  = sprintf("%-20s", skill.name);
          if player.level >= level then
            name = sprintf("<green>%s", name);
          end
          B.at(player, name);
          i = i + 1
          if i % 3 == 0 then say(); end
          ::nextcontinue::
        end

        if #abilities.spells > 0 then say("\r\n<bold>Spells"); end

        for _, spellId in ipairs(abilities.spells) do
          local spell = state.SpellManager:get(spellId);

          if not spell then
            Logger.error(sprintf("Invalid spell in ability table: %q:%q:%q",
                                 player.playerClass.name, level, spellId));
            goto spellcontinue
          end

          local name  = sprintf("%-20s", spell.name);
          if player.level >= level then
            name = sprintf("<green>%s", name)
          end
          B.at(player, name);
          i = i + 1
          if i % 3 == 0 then say() end
          ::spellcontinue::
        end

        -- end with a line break
        say();
        ::continue::
      end
    end
  end,
};
