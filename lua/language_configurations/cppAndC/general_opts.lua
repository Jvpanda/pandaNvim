---@alias Configuration
---| "Generic"
---| "Bare Metal Embedded"
---| "Zephyr"
---| "ROS2"

---@alias BuildType
---| "Debug"
---| "Release"

---@alias RunWindow
---| "external"
---| "floatingWindow"
---| "window"
---| "external_permanent"

---@alias DebugRunStart
---| "Run"
---| "Stop"

---@alias Debugger
---| "GDB"
---| "RADDBG"

---@class FloatingWindowSize
---@field heightRatio number
---@field widthRatio number
---@field col integer
---@field row integer

---@class Options
---@field configuration Configuration
---@field buildType BuildType
---@field runWindow RunWindow
---@field vimFloatingWindowSize FloatingWindowSize
---@field debugRunStart DebugRunStart
---@field debugger Debugger
---@field terminal string?
---@field backupTerminal string?
---@field compileFlags string
---@field buildFlags string
local opts = {
    configuration = "Generic",
    buildType = "Debug",
    runWindow = "external",
    vimFloatingWindowSize = { heightRatio = 0.45, widthRatio = 0.25, col = 1, row = 0 },
    debugRunStart = "Run",
    debugger = "GDB",
    terminal = nil,
    backupTerminal = nil,
    compileFlags = "",
    buildFlags = "",
}

return opts
