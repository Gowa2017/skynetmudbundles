local class      = require("pl.class")

local dir        = require("pl.dir")
local path       = require("pl.path")
local wrapper    = require("core.lib.wrapper")

local classesDir = "bundles/bundle-example-classes/classes"
local classes   

--
-- Base player class
---@class PlayerClass : Class
local M          = class()

function M.getClasses()
  if classes then return classes end
  classes = {}
  local files = dir.getfiles(classesDir)
  for _, filePath in ipairs(files) do
    local _, fileName = path.splitpath(filePath)
    local id, _       = path.splitext(fileName)
    local config      = wrapper.loadScript(filePath)
    classes[id] = M(id, config)
  end
  return classes
end
function M.get(id) return M.getClasses()[id] end

---
---@param id string id  id corresponding to classes/<id>.js file
---@param config any config Definition, self object is completely arbitrary. In
---    self example implementation it has a name, description, and ability
---    table. You are free to change self class as you wish
function M:_init(id, config)
  self.id = id
  self.config = config

end

---
---Override self method in your class to do initial setup of the player. This
---includes things like adding the resource attribute to the player or anything
---else that should be done when the player is initially given self class
---@param state GameState state
---@param player Player player
function M:setupPlayer(state, player)
  if type(self.config.setupPlayer) == "function" then
    self.config.setupPlayer(state, player);
  end
end

---
---Table of level: abilities learned.
---Example:
---    {
---      1: { skills: ['kick'] },
---      2: { skills: ['bash'], spells: ['fireball']},
---      5: { skills: ['rend', 'secondwind'] },
---    }
function M:abilityTable() return self.config.abilityTable; end

function M:abilityList()
  local res = {}
  for _, abilities in pairs(self:abilityTable()) do
    if abilities.skills then
      for _, skill in ipairs(abilities.skills) do res[#res + 1] = skill end
    end
    if abilities.spells then
      for _, spell in ipairs(abilities.spells) do res[#res + 1] = spell end
    end

  end
  return res
end

--
-- Get a flattened list of all the abilities available to a given player
---@param player Player player
---@return string[] #Array of ability ids
function M:getAbilitiesForPlayer(player)
  local totalAbilities = {};
  for level, abilities in pairs(self:abilityTable()) do
    if level > player.level then goto continue end
    if abilities.skills then
      for _, skill in ipairs(abilities.skills) do res[#res + 1] = skill end
    end
    if abilities.spells then
      for _, spell in ipairs(abilities.spells) do res[#res + 1] = spell end
    end

    ::continue::
  end
  return totalAbilities;
end

---
---Check to see if self class has a given ability
---@param id string id
---@return boolean
function M:hasAbility(id)
  for _, abilityId in ipairs(self:abilityList()) do
    if abilityId == id then return true end

  end
  return false
end

---
---Check if a player can use a given ability
---@param player Player player
---@param abilityId string abilityId
---@return boolean
function M:canUseAbility(player, abilityId)
  for _, id in ipairs(self:getAbilitiesForPlayer(player)) do
    if id == abilityId then return true end
  end
  return false
end

return M
