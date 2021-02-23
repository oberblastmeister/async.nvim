local a = require('async/async')
local uv = vim.loop

local M = {}

-- filesystem
M.fs_open = a.wrap(uv.fs_open)
M.fs_fstat = a.wrap(uv.fs_fstat)
M.fs_read = a.wrap(uv.fs_read)
M.fs_close = a.wrap(uv.fs_close)
M.fs_unlink = a.wrap(uv.fs_unlink)
M.fs_write = a.wrap(uv.fs_write)
M.fs_mkdir = a.wrap(uv.fs_mkdir)

return M
