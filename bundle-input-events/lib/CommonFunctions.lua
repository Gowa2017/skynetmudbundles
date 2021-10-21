local Config = require("core.Config")

local M      = {}
function M.validateName(name)
  local maxLength = Config.get("maxAccountNameLength");
  local minLength = Config.get("minAccountNameLength");

  if not name then return "Please enter a name."; end
  if #name > maxLength then return "Too long, try a shorter name."; end

  if #name < minLength then return "Too short, try a longer name."; end
  if not name:match("^[%a]+$") then
    return
      "Your name may only contain A-Z without spaces or special characters.";
  end
  return false;
end

return M
