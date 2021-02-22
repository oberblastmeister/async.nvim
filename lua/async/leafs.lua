local a = require('async')
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

-- M.read_file = a.wrap(function())

M.e2 = a.sync(function(msg1, msg2, ms)
  a.wait(M.sleep(ms))
  return msg1, msg2
end)

local async_task = a.sync(function()
  local x, y = a.wait(M.e2(5, 10, 200))
  print(x, y)
end)

async_task()()

return M
