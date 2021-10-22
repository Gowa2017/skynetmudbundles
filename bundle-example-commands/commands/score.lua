local sprintf = string.format
local B       = require("core.Broadcast")

local wrapper = require("core.lib.wrapper")

local Combat  = wrapper.loadBundleScript("lib/Combat", "bundle-example-combat");

return {
  aliases = { "stats" },
  command = function(state)
    return function(self, args, p)
      local say          = function(message) B.sayAt(p, message) end;

      -- say('<bold>' .. B.center(60, sprintf("${p.name}, level ${p.level} ${p.playerClass.config.name}",p.name,p.level,p.playerClass), 'green'));
      say("<bold>" .. B.center(60, sprintf("%q, level %q %q", p.name, p.level,
                                           p.playerClass.config.name), "green"));
      say("<bold>" .. B.line(60, "-", "green"));

      local stats        = {
        strength  = 0,
        agility   = 0,
        intellect = 0,
        stamina   = 0,
        armor     = 0,
        health    = 0,
        critical  = 0,
      };
      for stat, _ in pairs(stats) do

        stats[stat] = {
          current = p:getAttribute(stat) or 0,
          base    = p:getBaseAttribute(stat) or 0,
          max     = p:getMaxAttribute(stat) or 0,
        };
      end

      B.at(p, sprintf(" %-9s: %12s", "Health",
                      stats.health.current / stats.health.max));
      say("<bold><green>" .. sprintf("%36s", "Weapon "));

      -- class resource
      local classId      = p.playerClass.id
      if classId == "warrior" then
        local energy = {
          current = p:getAttribute("energy"),
          max     = p:getMaxAttribute("energy"),
        };
        B.at(p, sprintf(" %-9s: %12s", "Energy", energy.current / energy.max));
      elseif classId == "mage" then
        local mana = {
          current = p:getAttribute("mana"),
          max     = p:getMaxAttribute("mana"),
        };
        B.at(p, sprintf(" %-9s: %12s", "Mana", mana.current / mana.max));
      elseif classId == "paladin" then
        local favor = {
          current = p:getAttribute("favor"),
          max     = p:getMaxAttribute("favor"),
        };
        B.at(p, sprintf(" %-9s: %12s", "Favor", favor.current / favor.max));
      else

        B.at(p, B.line(24, " "));
      end
      say(sprintf("%35s", "." .. B.line(22)) .. ".");

      B.at(p, sprintf("%37s", "|"));
      local weaponDamage = Combat.getWeaponDamage(p);
      local min          = Combat.normalizeWeaponDamage(p, weaponDamage.min);
      local max          = Combat.normalizeWeaponDamage(p, weaponDamage.max);
      say(sprintf(" %6s:<bold>%5s - <bold>%-5s |", "Damage", min, max));
      B.at(p, sprintf("%37s", "|"));
      say(sprintf(" %6s: <bold>%12s |", "Speed",
                  B.center(12, Combat.getWeaponSpeed(p) .. " sec")));

      say(sprintf("%60s", "'" .. B.line(22) .. "'"));

      say("<bold><green>" .. sprintf("%-24s", " Stats"))
      say("." .. B.line(22) .. ".");

      local printStat    = function(stat, newline)
        newline = newline == nil and true or newline
        local val       = stats[stat];
        local statColor = (val.current > val.base and "green" or "white");
        local str       = sprintf("| %-9s : <bold><%s>%8s |",
                                  stat:sub(1, 1):upper() .. stat:sub(2),
                                  statColor, val.current);

        if newline then
          say(str);
        else
          B.at(p, str);
        end
      end;

      printStat("strength", false); -- left
      say("<bold><green>" .. sprintf("%36s", "Gold ")); -- right
      printStat("agility", false); -- left
      say(sprintf("%36s", "." .. B.line(12) .. ".")); -- right
      printStat("intellect", false); -- left
      say(sprintf("%22s| <bold>%10s |", "", p:getMeta("currencies.gold") or 0)); -- right
      printStat("stamina", false); -- left
      say(sprintf("%36s", "'" .. B.line(12) .. "'")); -- right

      say(":" .. B.line(22) .. ":");
      printStat("armor");
      printStat("critical");
      say("'" .. B.line(22) .. "'");
    end
  end,
};
