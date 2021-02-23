local a = require('async/async')
local VecDeque = require('async/helpers').VecDeque
local uv = vim.loop

local M = {}

M.sleep = a.wrap(function(ms, callback)
  local timer = uv.new_timer()
  uv.timer_start(timer, ms, 0, function()
    uv.timer_stop(timer)
    uv.close(timer)
    callback()
  end)
end)

M.timer = function(ms)
  return a.sync(function()
    a.wait(M.sleep(ms))
  end)
end

M.id = a.sync(function(...)
  return ...
end)

local Condvar = {}
Condvar.__index = Condvar

function Condvar.new()
  return setmetatable({handles = {}}, Condvar)
end

--- async function
--- blocks the thread until a notification is received
Condvar.wait = a.wrap(function(self, callback)
  -- not calling the callback will block the coroutine
  table.insert(self.handles, callback)
end)

function Condvar:notify_all()
  for _, callback in ipairs(self.handles) do
    callback()
  end
  self.handles = {} -- reset all handles as they have been used up
end

function Condvar:notify_one()
  if #self.handles == 0 then return end

  local idx = math.random(#self.handles)
  self.handles[idx]()
  table.remove(self.handles, idx)
end

M.Condvar = Condvar

return M
