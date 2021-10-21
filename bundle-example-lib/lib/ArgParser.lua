local tablex  = require("pl.tablex")

local stringx = require("pl.stringx")
local M       = {}

---
---Parse "get 2.foo bar"
---@param search string   search    2.foo
---@param list table list      Where to look for the item
---@param returnKey boolean  returnKey If `list` is a Map, true to return the KV tuple instead of just the entry
---@return boolean # Boolean on error otherwise an entry from the list
---
function M.parseDot(search, list, returnKey)
  returnKey = returnKey == nil and false
  if not list then return end

  local parts       = stringx.split(search, ".")
  local findNth     = 1;
  local keyword    
  if #parts > 2 then return false end

  if #parts == 1 then
    keyword = parts[1]
  else
    findNth = tonumber(parts[1])
    keyword = parts[2]
  end

  local encountered = 0;
  for _, entity in pairs(list) do
    local key, entry
    if type(entity) == "table" then
      key, entry = entity.key, entity
    else
      entry = entity
    end
    if not entry.name and not entry.keywords then
      error("Items in list have no keyword or name")
    end
    -- prioritize keywords over item/player names
    local pretty     = require("pl.pretty")
    if entry.keywords and
      (tablex.find(entry.keywords, keyword) or entry.uuid == keyword) then
      encountered = encountered + 1
      if encountered == findNth then
        if returnKey then
          return key, entry
        else
          return entry
        end
      end
      goto continue
    end
    if entry.name and entry.name:lower():find(keyword:lower()) then
      encountered = encountered + 1
      if encountered == findNth then
        if returnKey then
          return key, entry
        else
          return entry
        end
      end
    end
    ::continue::
  end
  return false;
end

return M
