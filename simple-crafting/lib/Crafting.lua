local wrapper          = require("core.lib.wrapper")
local Item             = require("core.Item")
local dataPath         = "bundle/simple-crafting/data/";
local _loadedResources = wrapper.loadBundleScript("data/resources");
local _loadedRecipes   = wrapper.loadBundleScript("data/recipes");

local M                = {}

function M.getResource(resourceKey) return _loadedResources[resourceKey]; end

function M.getResourceItem(resourceKey)
  local resourceDef = M.getResource(resourceKey);
  -- create a temporary fake item for the resource for rendering purposes
  return Item(nil, {
    name     = resourceDef.title,
    metadata = { quality = resourceDef.quality },
    keywords = resourceKey,
    id       = 1,
  });
end

function M.getRecipes() return _loadedRecipes; end

return M
