local co = coroutine

-- use with wrap
local pong = function(func, callback)
  assert(type(func) == "function", "type error :: expected func")
  local thread = co.create(func)
  local step = nil
  step = function (...)
    local res = {co.resume(thread, ...)}
    local stat = res[1]
    local ret = {select(2, unpack(res))}
    assert(stat, "Status should be true")
    if co.status(thread) == "dead" then
      (callback or function() end)(unpack(ret))
    else
      assert(#ret == 1, "expected a single return value")
      assert(type(ret[1]) == "function", "type error :: expected func")
      ret[1](step)
    end
  end
  step()
end


-- use with pong, creates thunk factory
local wrap = function(func)
  assert(type(func) == "function", "type error :: expected func")

  return function(...)
    local params = {...}
    return function(step)
      table.insert(params, step)
      return func(unpack(params))
    end
  end
end


-- many thunks -> single thunk
local join = function(thunks)
  local len = #thunks
  local done = 0
  local acc = {}

  local thunk = function(step)
    if len == 0 then
      return step()
    end
    for i, tk in ipairs(thunks) do
      assert(type(tk) == "function", "thunk must be function")
      local callback = function (...)
        acc[i] = {...}
        done = done + 1
        if done == len then
          step(unpack(acc))
        end
      end
      tk(callback)
    end
  end
  return thunk
end


-- sugar over coroutine
local await = function(defer)
  assert(type(defer) == "function", "type error :: expected func")
  return co.yield(defer)
end


local await_all = function(defer)
  assert(type(defer) == "table", "type error :: expected table")
  return co.yield(join(defer))
end

local async = function(func)
  return function(...)
    local args = {...}
    return wrap(pong)(function()
      return func(unpack(args))
    end)
  end
end

return {
  sync = async,
  wait = await,
  wait_all = await_all,
  wrap = wrap,
  wait_for_textlock = wrap(vim.schedule)
} 
