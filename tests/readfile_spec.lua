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

local function read_a_bunch()
  local results = a.wait_all {read_file("/home/brian/vim.log"), read_file("/home/brian/test.log"), read_file("/home/brian/README.md")}
  dump(results)
end
