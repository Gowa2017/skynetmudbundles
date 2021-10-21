---
---These formulas are stolen straight from WoW.
---See: http://www.wowwiki.com/Formulas:XP_To_Level
---
---
---Extra difficulty factor to level
---@param level number
local function reduction(level)
  local val
  if level <= 10 then
    val = 1
  elseif level >= 11 and level <= 27 then
    val = 1 - (level - 10) / 100
  elseif level >= 28 and level <= 59 then
    val = 0.82
  else
    val = 1
  end

  return val
end

---
---Difficulty modifier starting around level 30
---@param level integer
---@return integer
local function diff(level)
  if level <= 28 then
    return 0
  elseif level == 29 then
    return 1
  elseif level == 30 then
    return 3
  elseif level == 31 then
    return 6
  elseif level >= 32 and level <= 59 then
    return 5 * (level - 30)
  end
end

local LevelUtil = {}
---
---Get the exp that a mob gives
---@param level integer
---@return integer
LevelUtil.mobExp = function(level) return 45 + (5 * level) end

---Helper to get the amount of experience a player needs to level
---@param level integer Target level
---@return integer
LevelUtil.expToLevel = function(level)
  return math.floor(((4 * level) + diff(level)) * LevelUtil.mobExp(level) *
                      reduction(level))
end

return LevelUtil
