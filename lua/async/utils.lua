local a = require('async/async')
local co = coroutine
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

M.thread_loop = function(thread, callback)
  local idle = uv.new_idle()
  idle:start(function()
    local success = co.resume(thread)
    assert(success, "Coroutine failed")

    if co.status(thread) == "dead" then
      idle:stop()
      callback()
    end
  end)
end

M.thread_loop_async = a.wrap(M.thread_loop)

M.yield_now = a.sync(function()
  a.wait(M.id())
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

--- not an async function
function Condvar:notify_all()
  for _, callback in ipairs(self.handles) do
    callback()
  end
  self.handles = {} -- reset all handles as they have been used up
end

--- not an async function
function Condvar:notify_one()
  if #self.handles == 0 then return end

  local idx = math.random(#self.handles)
  self.handles[idx]()
  table.remove(self.handles, idx)
end

M.Condvar = Condvar

M.channel = {}

---comment
---@return function
---@return any
M.channel.oneshot = function()
  local val = nil
  local saved_callback = nil

  --- sender is not async
  --- sends a value
  local sender = function(t)
    if val ~= nil then
      error('Oneshot channel can only send one value!')
    end

    val = t
    saved_callback(val)
  end

  --- receiver is async
  --- blocks until a value is received
  local receiver = a.wrap(function(callback)
    if callback ~= nil then
      error('Oneshot channel can only receive one value!')
    end

    saved_callback = callback
  end)

  return sender, receiver
end

M.channel.mpsc = function()
end

return M
