local a = require('async')
local Condvar = a.utils.Condvar

counter = 0

condvar = Condvar.new()

local first = a.sync(function()
  a.wait(condvar:wait())
  print('after first')
  counter = counter + 1
end)

local second = a.sync(function()
  a.wait(condvar:wait())
  print('after second')
  counter = counter + 1
end)

local third = a.sync(function()
  a.wait(condvar:wait())
  print('after third')
  counter = counter + 1
end)

-- local all = a.sync(function()
--   a.wait_all { first, second, third }
-- end)

a.run_all { first, second, third }
-- a.run(all)
