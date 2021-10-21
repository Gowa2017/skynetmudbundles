local wrapper = require("core.lib.wrapper")

local M       = {}
M.InvalidCommandError = wrapper.errortype("InvalidCommandError")
M.RestrictedCommandError = wrapper.errortype("RestrictedCommandError")
return M
