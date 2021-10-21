local B = require("core.Broadcast")
return {
  usage   = "map",
  command = function(state)
    return function(self, args, player)
      local room   = player.room
      if not room or not room.coordinates then
        return B.sayAt(player, "You can't see a map in this room")
      end
      local size   = tonumber(args)
      size = type(size) == "number" and 4 or size - (size % 2)
      local xSize  = math.ceil(size * 2)
      xSize = math.max(2, xSize - (xSize % 2))
      if not size or size > 14 then size = 1 end
      local coords = room.coordinates
      local map    = "." .. string.rep("-", xSize * 2 + 1) .. "\r\n"
      for y = coords.y + size, coords.y - size, -1 do
        map = map .. "|"
        for x = coords.x - xSize, coords.x + xSize, 1 do
          if x == coords.x and y == coords.y then
            map = map .. "<yellow>@"
          elseif room.area:getRoomAtCoordinates(x, y, coords.z) then
            local hasUp   = room.area:getRoomAtCoordinates(x, y, coords + 1)
            local hasDown = room.area:getRoomAtCoordinates(x, y, coords - 1)
            if hasUp and hasDown then
              map = map .. "%%"
            elseif hasUp then
              map = map .. "←"
            elseif hasDown then
              map = map .. "→"
            else
              map = map .. "."
            end
          else
            map = map .. " "
          end
        end
        map = map .. "\r\n"
      end
      map = map .. "'" .. string.rep("-", xSize * 2 + 1) .. "'"
      B.sayAt(player, map)
    end
  end,
}
