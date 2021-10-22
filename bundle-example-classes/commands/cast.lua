local Broadcast = require("core.Broadcast")

return {
  command = function(state)
    return function(self, args, player)
      -- match cast "fireball" target
      -- local match = args.match('/^(['"])([^\1]+)+\1(?:$|\s+(.+)$)/');
      if not match then
        return Broadcast.sayAt(player,
                               "Casting spells must be surrounded in quotes e.g., cast 'fireball' target");
      end

      local _, _, spellName, targetArgs = nil, nil, nil, nil
      local spell                       = state.SpellManager:find(spellName);

      if not spell then return Broadcast.sayAt(player, "No such spell."); end

      player:queueCommand({
        execute = function()
          player:emit("useAbility", spell, targetArgs);
        end,
        label   = "cast " .. args,
      }, spell.lag or state.Config.get("skillLag") or 1);
    end
  end,
};
