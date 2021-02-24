## important

This is probably going to get merged into plenary [here](https://github.com/nvim-lua/plenary.nvim/pull/83). This has only the basic features. Check out the pull request to see all the features or see the [list](#Other-features).

# async.nvim

Never get into callback hell again. This library tries to wrap libuv into a futures-like api to make using async simple and easy.

## Examples

This is the example provided by libuv luv for a simple filesystem function
```lua
local read_file = function(path, callback)
  uv.fs_open(path, "r", 438, function(err, fd)
    assert(not err, err)
    uv.fs_fstat(fd, function(err, stat)
      assert(not err, err)
      uv.fs_read(fd, stat.size, 0, function(err, data)
        assert(not err, err)
        print(data)
        uv.fs_close(fd, function(err)
          assert(not err, err)
          return callback(data)
        end)
      end)
    end)
  end)
end
```

I don't ever want to get here!
![nested](https://alistairb.dev/images/hadouken.jpeg)

```lua
local a = require('async')

local read_file = a.sync(function(path)
  local err, fd = a.wait(a.uv.fs_open(path, "r", 438))
  assert(not err, err)

  local err, stat = a.wait(a.uv.fs_fstat(fd))
  assert(not err, err)

  local err, data = a.wait(a.uv.fs_read(fd, stat.size, 0))
  assert(not err, err)
  print(data)

  local err = a.wait(a.uv.fs_close(fd))
  assert(not err, err)
end)
```

This is just for the filesystem. This library will try to wrap as much of the libuv api as possible. There are also some goodies in `a.utils`

## Other features

- try to have a async await wrapper for every libuv async function that takes a callback (need to wrap more functions)
- utilities such as `sleep` (better than vim.wait, does not block interface)
- condvar (block until a notification is received)
- channels (block until a value is received)
    * mspc
    * oneshot
    * broadcast (wip)
- idle abstraction(wip)
- async await abstraction for jobs (wip)
- events (such as nvim_buf_attach, filesystem events, timer events, anything that will do a callback multiple times) (wip)
    * call await on an event to get it, no need for callbacks
    * currently events will be starting the function with the callback as the sender part of the channel. await-ing the event will 'block' until something is received from the channel
- more coming

## Credit

This library was made possible by [neovim-async-tutorial](https://github.com/ms-jpq/neovim-async-tutorial). It is also inspired by some parts of [neogit](https://github.com/TimUntersberger/neogit/pull/42)
