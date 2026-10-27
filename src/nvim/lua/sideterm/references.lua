local M = {}

-- Find the running shell's current directory using procfs or lsof
local function shell_directory(job_id)
  if not job_id or vim.fn.jobwait({ job_id }, 0)[1] ~= -1 then
    return
  end
  local pid = vim.fn.jobpid(job_id)
  local cwd = vim.uv.fs_readlink("/proc/" .. pid .. "/cwd")
  if cwd then
    return cwd
  end
  if vim.fn.executable("lsof") == 0 then
    return
  end
  local result = vim.system({ "lsof", "-a", "-p", tostring(pid), "-d", "cwd", "-Fn" }, { text = true }):wait(1000)
  if result.code == 0 then
    for line in result.stdout:gmatch("[^\n]+") do
      if line:sub(1, 1) == "n" then
        return line:sub(2)
      end
    end
  end
end

-- Select the path[:line[:column]] reference at the given position, excluding paths containing whitespace
local function parse(text, column)
  -- The empty captures mark the bounds so we select the reference under the cursor
  for first, path, line, col, last_column in text:gmatch("()([^%s\"'<>|%(%)%[%]:]+):?(%d*):?(%d*)()") do
    if column >= first and column < last_column then
      return { path = path, line = tonumber(line) or 1, column = tonumber(col) or 1 }
    end
  end
end

-- Resolve a file or directory reference at a one-based terminal row and column using the shell's current directory
function M.resolve(bufnr, job_id, row, column)
  local text = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
  local reference = parse(text, column)
  if not reference then
    return nil, "No path reference under cursor", vim.log.levels.INFO
  end

  local path = reference.path
  if path:sub(1, 2) == "~/" then
    path = vim.uv.os_homedir() .. path:sub(2)
  end
  if path:sub(1, 1) ~= "/" then
    local cwd = shell_directory(job_id)
    if not cwd then
      return nil, "Cannot determine terminal shell directory", vim.log.levels.WARN
    end
    path = vim.fs.joinpath(cwd, path)
  end
  path = vim.fs.normalize(path)
  reference.is_directory = vim.fn.isdirectory(path) == 1
  if not reference.is_directory and vim.fn.filereadable(path) == 0 then
    return nil, "Path not found: " .. path, vim.log.levels.WARN
  end

  reference.path = path
  return reference
end

return M
