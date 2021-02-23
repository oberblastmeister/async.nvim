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

## Credit

This library was made possible by [neovim-async-tutorial](https://github.com/ms-jpq/neovim-async-tutorial). It is also inspired by some parts of [neogit](https://github.com/TimUntersberger/neogit/pull/42)
