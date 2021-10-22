local wrapper      = require("core.lib.wrapper")
local tablex       = require("pl.tablex")
local stringx      = require("pl.stringx")
local humanize     = wrapper.humanize
local B            = require("core.Broadcast")
local Logger       = require("core.Logger")
local SkillErrors  = require("core.SkillErrors")

local Combat       = wrapper.loadBundleScript("lib/Combat",
                                              "bundle-example-combat");
local CombatErrors = wrapper.loadBundleScript("lib/CombatErrors",
                                              "bundle-example-combat");

return {
  listeners = {
    useAbility = function(state)
      return function(self, ability, args)
        if not self.playerClass:hasAbility(ability.id) then
          return B.sayAt(self, "Your class cannot use that ability.");
        end

        if self.playerClass:canUseAbility(self, ability.id) then
          return B.sayAt(self, "You have not yet learned that ability.");
        end
        local target

        if ability.requiresTarget then
          if not args or #args < 1 then
            if ability.targetSelf then
              target = self;
            elseif self:isInCombat() then
              target = tablex.keys(self.combatants)[1];
            else
              target = nil;
            end
          else

            local targetSearch = table.remove(stringx.split(args))
            local ok, e        = xpcall(function()
              target = Combat.findCombatant(self, targetSearch)
            end, debug.traceback)
            if not ok then
              if e == CombatErrors.CombatSelfError or e ==
                CombatErrors.CombatNonPvpError or e ==
                CombatErrors.CombatInvalidTargetError or e ==
                CombatErrors.CombatPacifistError then
                return B.sayAt(self, e);
              end

              Logger.error(e);

            end
          end

          if not target then
            return B.sayAt(self, string.format("Use %s on whom?", ability.name));
          end
        end

        local ok, e  = xpcall(ability.execute, debug.traceback, ability, args,
                              self, target)
        if not ok then
          if e == SkillErrors.CooldownError then
            if ability.cooldownGroup then
              return B.sayAt(self,
                             string.format(
                               "Cannot use %s while %s is on cooldown.",
                               ability.name, e.effect.skill.name));
            end
            return B.sayAt(self,
                           string.format("%s is on cooldown. %s remaining.",
                                         ability.name,
                                         humanize(e.effect.remaining)));
          end
          if e == SkillErrors.PassiveError then
            return B.sayAt(self, "That skill is passive.");
          end
          if e == SkillErrors.NotEnoughResourcesError then
            return B.sayAt(self, "You do not have enough resources.");
          end

          Logger.error(e);
          B.sayAt(self, "Huh?");
        end
      end
    end,

    ---
    ---Handle player leveling up
    ---
    level      = function(state)
      return function(self)
        local abilities = self.playerClass:abilityTable();
        if not self.playerClass:abilityTable()[self.level] then return end

        local newSkills = abilities[self.level].skills or {};
        for _, abilityId in ipairs(newSkills) do
          local skill = state.SkillManager:get(abilityId);
          B.sayAt(self, string.format(
                    "<bold><yellow>You can now use skill: %s.", skill.name));
          skill:activate(self);
        end

        local newSpells = abilities[self.level].spells or {}
        for _, abilityId in ipairs(newSpells) do
          local spell = state.SpellManager:get(abilityId);
          B.sayAt(self, string.format(
                    "<bold><yellow>You can now use spell: %s.", spell.name));
        end
      end
    end,
  },
};
