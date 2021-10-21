local Config       = require("core.Config")
local B            = require("core.Broadcast")
local wrapper      = require("core.lib.wrapper")
local sfmt         = string.format
local Logger       = require("core.Logger")

local Combat       = wrapper.loadBundleScript("lib/Combat",
                                              "bundle-example-combat");
local CombatErrors = wrapper.loadBundleScript("lib/CombatErrors",
                                              "bundle-example-combat");
local LevelUtil    = wrapper.loadBundleScript("lib/LevelUtil",
                                              "bundle-example-lib");
-- const WebsocketStream = require('../websocket-networking/lib/WebsocketStream');

local function promptBuilder(promptee)
  if not promptee:isInCombat() then return ""; end

  -- Set up some constants for formatting the health bars
  local playerName          = "You";
  local targetNameLengths   = {}
  for t, _ in pairs(promptee.combatants) do
    targetNameLengths[#targetNameLengths + 1] = #t.name
  end
  local nameWidth           = math.max(#playerName,
                                       table.unpack(targetNameLengths));
  local progWidth           = 60 - #(nameWidth .. ":  ")

  -- Set up helper functions for health-bar-building.
  local getHealthPercentage = function(entity)
    return math.floor((entity:getAttribute("health") /
                        entity:getMaxAttribute("health")) * 100)
  end;
  local formatProgressBar   = function(name, progress, entity)
    local pad = B.line(nameWidth - name.length, " ");
    return sfmt("<bold>%s%s: %q <bold>%q/%q", name, pad, progress,
                entity:getAttribute("health"), entity:getMaxAttribute("health"));
  end

  -- Build player health bar.
  local currentPerc         = getHealthPercentage(promptee);
  local progress            = B.progress(progWidth, currentPerc, "green");
  local buf                 = formatProgressBar(playerName, progress, promptee);

  -- Build and add target health bars.
  for target, _ in pairs(promptee.combatants) do
    local currentPerc = math.floor((target:getAttribute("health") /
                                     target:getMaxAttribute("health")) * 100);
    local progress    = B.progress(progWidth, currentPerc, "red");
    buf = buf ..
            sfmt("\r\n%q", formatProgressBar(target.name, progress, target));
  end

  return buf;
end
---
---Auto combat module
---
return {
  listeners = {
    updateTick = function(state)
      return function(self)
        Combat.startRegeneration(state, self);

        local hadActions      = false;
        local ok, e           = pcall(function()
          hadActions = Combat.updateRound(state, self)
        end)
        if not ok then
          if e == CombatErrors.CombatInvalidTargetError then
            B.sayAt(self, "You cant' attack that target")
          else
            error(e)
          end
        end
        if not hadActions then return end

        -- local usingWebsockets = self.socket instanceof WebsocketStream;
        local usingWebsockets = false
        -- don't show the combat prompt to a websockets server
        if not self:hasPrompt("combat" and not usingWebsockets) then
          self:addPrompt("combat", function() promptBuilder(self) end)
        end

        B.sayAt(self, "");
        if not usingWebsockets then B.prompt(self) end
      end
    end,

    hit        = function(state)
      ---When the player hits a target
      ---@param damage Damage damage
      ---@param target Character target
      return function(self, damage, target, finalAmount)
        if damage.metadata.hidden then return end

        local buf = ""
        if damage.source ~= self then
          buf = sfmt("Your <bold>%s> hit", damage.source.name);
        else
          buf = "You hit";
        end

        buf = buf ..
                sfmt(" <bold> %s for <bold>%s damage.", target.name, finalAmount);

        if damage.metadata.critical then
          buf = buf .. " <red><bold>(Critical)";
        end

        B.sayAt(self, buf);

        if self.equipment["wield"] then
          self.equipment["wield"]:emit("hit", damage, target, finalAmount);
        end

        -- show damage to party members
        if not self.party then return; end

        for member, _ in pairs(self.party.members) do
          if member == self or member.room ~= self.room then
            goto continue
          end
          local buf = ""
          if damage.source ~= self then
            buf = sfmt("%s <bold>%s hit", self.name, damage.source.name);
          else
            buf = sfmt("%s hit", self.name);
          end

          buf = buf ..
                  sfmt(" <bold>%s for <bold>%q damage.", target.name,
                       finalAmount);
          B.sayAt(member, buf);
          ::continue::
        end
      end
    end,

    heal       = function(state)
      ---@param heal Heal heal
      ---@param target Character target
      return function(self, heal, target, finalAmount)
        if heal.metadata.hidden then return end

        if target ~= self then
          local buf = "";
          if heal.source ~= self then
            buf = sfmt("Your <bold>%q healed", heal.source.name);
          else
            buf = "You heal";
          end

          buf = buf ..
                  sfmt("<bold> %q for <bold><green>%q %q.", target.name,
                       finalAmount, heal.attribute);
          B.sayAt(self, buf);
        end

        -- show heals to party members
        if not self.party then return; end

        for member, _ in pairs(self.party.members) do
          if member == self or member.room ~= self.room then
            goto continue
          end

          local buf = "";
          if heal.source ~= self then
            buf = sfmt("%q <bold>%q healed", self.name, heal.source.name);
          else
            buf = sfmt("%q healed", self.name);
          end

          buf = buf .. sfmt(" <bold> %q", target.name);
          buf = buf ..
                  sfmt(" for <bold><green>%q %q.", finalAmount, heal.attribute);
          B.sayAt(member, buf);
          ::continue::
        end
      end
    end,

    damaged    = function(state)
      return function(self, damage, finalAmount)
        if damage.metadata.hidden or damage.attribute ~= "health" then
          return;
        end

        local buf = "";
        if damage.attacker then
          buf = sfmt("<bold>%s", damage.attacker.name);
        end

        if damage.source ~= damage.attacker then
          buf = buf .. (damage.attacker and "'s " or " ") ..
                  sfmt("<bold>%s", damage.source.name);
        elseif not damage.attacker then
          buf = buf .. "Something";
        end

        buf = buf ..
                sfmt(" hit <bold>You for <bold><red>%q damage.", finalAmount);

        if damage.metadata.critical then
          buf = buf .. " <red><bold>(Critical)";
        end

        B.sayAt(self, buf);

        if self.party then
          -- show damage to party members
          for member, _ in pairs(self.party.members) do
            if member == self or member.room ~= self.room then
              goto continue
            end

            local buf = "";
            if damage.attacker then
              buf = sfmt("<bold>%q", damage.attacker.name);
            end

            if damage.source ~= damage.attacker then
              buf = buf .. (damage.attacker and "'s " or " ") ..
                      sfmt("<bold>%q", damage.source.name);
            elseif not damage.attacker then
              buf = buf .. "Something";
            end

            buf = buf ..
                    sfmt(" hit <bold>%q for <bold><red>%q damage", self.name,
                         finalAmount);
            B.sayAt(member, buf);
            ::continue::
          end
        end

        if self:getAttribute("health") <= 0 then
          Combat.handleDeath(state, self, damage.attacker);
        end
      end
    end,

    healed     = function(state)
      return function(self, heal, finalAmount)
        if heal.metadata.hidden then return; end

        local buf      = "";
        local attacker = "";
        local source   = "";

        if heal.attacker and heal.attacker ~= self then
          attacker = sfmt("<bold>%q ", heal.attacker.name);
        end

        if heal.source ~= heal.attacker then
          attacker = attacker and attacker .. "'s " or "";
          source = sfmt("<bold>%q", heal.source.name);
        elseif not heal.attacker then
          source = "Something";
        end

        if heal.attribute == "health" then
          buf = sfmt("%q%q heals you for <bold><red>%q.", attacker, source,
                     finalAmount);
        else
          buf = sfmt("%q%q restores <bold>%q %q.", attacker, source,
                     finalAmount, heal.attribute);
        end
        B.sayAt(self, buf);

        -- show heal to party members only if it's to health and not restoring a different pool
        if not self.party or heal.attribute ~= "health" then return; end

        for member, _ in pairs(self.party.members) do
          if member == self or member.room ~= self.room then
            goto continue

            local buf = sfmt("%q%q heals %q for <bold><red>%q.", attacker,
                             source, self.name, finalAmount);
            B.sayAt(member, buf);
            ::continue::
          end
        end
      end
    end,

    killed     = function(state)
      local startingRoomRef = Config.get("startingRoom");
      if not startingRoomRef then
        Logger.error("No startingRoom defined in ranvier.json");
      end
      ---Player was killed
      ---@param killer Character killer
      return function(self, killer)
        self.removePrompt("combat");

        local othersDeathMessage = killer and
                                     sfmt(
                                       "<bold><red>%q collapses to the ground, dead at the hands of %q.",
                                       self.name, killer.name) or
                                     sfmt(
                                       "<bold><red>%q collapses to the ground, dead",
                                       self.name);

        B.sayAtExcept(self.room, othersDeathMessage,
                      (killer and { killer, self } or self));

        if self.party then
          B.sayAt(self.party, sfmt("<bold><green>%q was killed!", self.name));
        end

        self.setAttributeToMax("health");

        local home               = state.RoomManager:getRoom(self:getMeta(
                                                               "waypoint.home"));
        if not home then
          home = state.RoomManager:getRoom(startingRoomRef);
        end

        self:moveTo(home, function()
          state.CommandManager:get("look"):execute(nil, self);

          B.sayAt(self, "<bold><red>Whoops, that sucked!");
          if killer and killer ~= self then
            B.sayAt(self, sfmt("You were killed by %q.", killer.name));
          end
          -- player loses 20% exp gained self level on death
          local lostExp = math.floor(self.experience * 0.2);
          self.experience = self.experience - lostExp;
          self.save();
          B.sayAt(self, sfmt("<red>You lose <bold>%q experience!", lostExp));
          B.prompt(self);
        end);
      end;
    end,

    deathblow  = function(state)
      ---
      ---Player killed a target
      ---@param target Character target
      return function(self, target, skipParty)
        local xp = LevelUtil.mobExp(target.level);
        if self.party and not skipParty then
          -- if they're in a party proxy the deathblow to all members of the party in the same room.
          -- self will make sure party members get quest credit trigger anything else listening for deathblow
          for member, _ in pairs(self.party.members) do
            if member.room == self.room then
              member:emit("deathblow", target, true);
            end
          end
          return;
        end

        if target and not self:isNpc() then
          B.sayAt(self, sfmt("<bold><red>You killed %q!", target.name));
        end

        self:emit("experience", xp);
      end
    end,
  },
};
