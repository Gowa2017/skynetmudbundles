local Logger      = require("core.Logger")
local class       = require("pl.class")
local stringx     = require("pl.stringx")

local tablex      = require("pl.tablex")

local loadedPools = {}

--
-- A loot table is made up of one or more loot pools. The `roll()` method will
-- determine drops from the pools up to `maxItems` drops
--
---@class LootTabale : Class
local M           = class()
function M:_init(state, config)
  self.pools = config.pools or {}
  self.currencyRanges = config.currencies or nil
  self.options = tablex.update({ maxItems = 5 }, config.options or {})
  self:load(state)
end

function M:load(state)
  local resolved = {}
  for _, pool in ipairs(self.pools) do
    resolved[#resolved + 1] = self:resolvePool(state, pool)
  end
  self.pools = tablex.reduce(function(memo, v)
    memo[#memo + 1] = v
    return memo
  end, resolved, {})
end
function M:roll()
  local items = {}
  for _, pool in ipairs(self.pools) do
    if type(pool) ~= "table" then goto continue end
    if #items >= self.options.maxItems then break end
    for item, chance in ipairs(pool) do
      if math.random(100) < chance then items[#items + 1] = item end
    end
    if #items >= self.options.maxItems then break end
    ::continue::
  end
  return items

end

---
---Find out how much of the different currencies this NPC will drop
---@return table<string,number>[] #{name: string, amount: number} list
function M:currencies()
  if not self.currencyRanges then return nil end
  local result = {}
  for currency, entry in pairs(self.currencyRanges) do
    local amount = math.random(entry.min, entry.max)
    if amount then
      result[#result + 1] = { name   = currency, amount = amount }
    end
  end
  return result;
end

function M:resolvePool(state, pool)
  if type(pool) ~= "string" then return pool end

  -- otherwise pool entry is: "myarea:foopool" so try to load loot-pools.yml from the appropriate area
  local poolArea       = state.AreaManager:getAreaByReference(pool);
  if not poolArea then
    Logger.error("Invalid item pool area:$q", pool)
    return nil
  end
  if not loadedPools[poolArea.name] then
    local loader = state.EntityLoaderRegistry:get("loot-pools")
    loader:setBundle(poolArea.bundle)
    loader:setArea(poolArea.name)
    loadedPools[poolArea.name] = loader:fetchAll()
  end
  -- return Logger.error(`Area has no pools definition: ${pool}`);

  local availablePools = loadedPools[poolArea.name];

  local _, poolName    = stringx.split(pool, ":")

  if not availablePools[poolName] then
    Logger.error("Area item pools does not include %q", poolName);
    return nil;
  end

  local resolvedPool   = availablePools[poolName];
  -- resolved pool is just a single pool definition
  if type(resolvedPool) ~= "table" then
    pool = resolvedPool;
  else
    local nestedResolved = {};
    for _, nestedPool in ipairs(resolvedPool) do
      nestedResolved[#nestedResolved + 1] = self:resolvePool(state, nestedPool)
    end

    -- resolved pool is a meta pool (pool of pools) so recursively resolve it
    pool = tablex.reduce(function(memo, v)
      memo[#memo + 1] = v
      return memo
    end, nestedResolved, {})
  end

  return type(pool) == "table" and pool or pool
end

return M
