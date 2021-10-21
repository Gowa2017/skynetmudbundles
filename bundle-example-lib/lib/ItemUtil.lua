-- local sprintf       = require("sprintf-js").sprintf;
local B             = require("core.Broadcast")
local ItemType      = require("core.ItemType")
local tconcat       = table.concat
local tablex        = require("pl.tablex")
local pretty        = require("pl.pretty")
local sprintf       = string.format
local stringx       = require("pl.stringx")

local qualityColors = {
  poor      = { "bold", "black" },
  common    = { "bold", "white" },
  uncommon  = { "bold", "green" },
  rare      = { "bold", "blue" },
  epic      = { "bold", "magenta" },
  legendary = { "bold", "red" },
  artifact  = { "yellow" },
};

local exports       = {}
exports.qualityColors = qualityColors;

local function reversetable(t)
  local res = {}
  for i = #t, 1, -1 do res[#res + 1] = t[i] end
  return res
end
---
---Colorize the given string according to this item's quality
---@param item Item item
---@param string string string
---@return string
function qualityColorize(item, string)
  local colors = qualityColors[item.metadata.quality or "common"];
  local open   = "<" .. tconcat(colors, "><") .. ">";
  local close  = "</" .. tconcat(reversetable(colors), "></") .. ">";
  return open .. string -- .. close;
end
exports.qualityColorize = qualityColorize;

---
---Friendly display colorized by quality
---
exports.display = function(item) return qualityColorize(item, item.name); end;

---
---Render a pretty display of an item
---@param state GameState state
---@param item Item      item
---@param player Player    player
exports.renderItem = function(state, item, player)
  local buf    = qualityColorize(item, "." .. B.line(38) .. ".") .. "\r\n";
  buf = buf .. "| " .. qualityColorize(item, sprintf("%-36s", item.name)) ..
          " |\r\n";

  local props  = item.metadata;

  buf = buf ..
          sprintf("| %-36s |\r\n",
                  item.type == ItemType.ARMOR and "Armor" or "Weapon");
  if item.type == ItemType.WEAPON then
    buf = buf
    sprintf("| %-18s%18s |\r\n",
            sprintf("%q - %q Damage", props.minDamage, props.maxDamage),
            sprintf("Speed %q", props.speed));
    local dps = ((props.minDamage + props.maxDamage) / 2) / props.speed;
    buf = buf +
            sprintf("| %-36s |\r\n", sprintf("%.2f damage per second)", dps));
  elseif item.type == ItemType.ARMOR then
    buf = buf + sprintf("| %-36s |\r\n", item.metadata.slot[0]:upper() ..
                          item.metadata.slot.sub(2))
  elseif item.type == ItemType.CONTAINER then
    buf = buf +
            sprintf("| %-36s |\r\n", sprintf("Holds %q items", item.maxItems));
  end

  -- copy stats to make sure we don't accidentally modify it
  local stats  = tablex.copy(props.stats);

  -- always show armor first
  if stats.armor then
    buf = buf .. sprintf("| %-36s |\r\n", sprintf("%q Armor", stats.armor));
    stats.armor = nil
  end

  -- non-armor stats
  for stat, value in pairs(stats) do
    buf = buf ..
            sprintf("| %-36s |\r\n", (value > 0 and "+" or "") .. value .. " " +
                      stat[0]:upper() .. stat.sub(2));
  end

  -- custom special effect rendering
  if props.specialEffects then
    tablex.foreachi(function(effectText, idx)
      local text = stringx.split(B.wrap(effectText, 36), "\r\n");
      tablex.foreachi(function(textLine, idx)
        buf = buf + sprintf("| <b><green>%-36s</green></b> |\r\n", textLine);
      end)
    end, props.specialEffects)
  end

  if props.level then
    local cantUse = props.level > player.level and "<red>%-36s</red>" or "%-36s";
    buf = buf +
            sprintf("| " .. cantUse .. "|\r\n",
                    "Requires Level " .. tostring(props.level));
  end
  buf = buf + qualityColorize(item, "'" + B.line(38) + "'") + "\r\n";

  -- On use
  local usable = item:getBehavior("usable");
  if usable then
    if usable.spell then
      local useSpell = state.SpellManager:get(usable.spell);
      if useSpell then
        useSpell.options = usable.options;
        buf = buf + B.wrap("<b>On Use</b>: " .. useSpell:info(player), 80) ..
                "\r\n";
      end
    end

    if usable.effect and usable.config.description then
      buf = buf + B.wrap("<b>Effect</b>: " .. usable.config.description, 80) ..
              "\r\n";
    end

    if usable.charges then
      buf = buf + B.wrap(sprintf("%q Charges", usable.charges), 80) .. "\r\n";
    end
  end

  -- colorize border according to item quality
  buf = buf:gsub("%|", qualityColorize(item, "|"));
  return buf;
end

return exports
