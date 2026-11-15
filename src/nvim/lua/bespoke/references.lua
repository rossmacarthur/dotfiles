local M = {}

-- Select the path[:line[:column]] reference at the given position, excluding paths containing whitespace
local function parse(text, column)
  -- The empty captures mark the bounds so we select the reference under the cursor
  for first, path, line, col, last_column in text:gmatch("()([^%s\"'<>|%(%)%[%]:]+):?(%d*):?(%d*)()") do
    if column >= first and column < last_column then
      if first == 5 and (text:match("^%-%-%- a/") or text:match("^%+%+%+ b/")) then
        path = path:sub(3)
      end
      return { path = path, line = tonumber(line) or 1, column = tonumber(col) or 1 }
    end
  end
end

-- Resolve a file or directory reference at a one-based column in terminal text
-- using the shell's current directory and its ancestors
function M.resolve(text, cwd, column)
  local reference = parse(text, column)
  if not reference then
    return nil, "No path reference under cursor", vim.log.levels.INFO
  end

  local path = reference.path
  if path:sub(1, 2) == "~/" then
    path = vim.uv.os_homedir() .. path:sub(2)
  end
  if path:sub(1, 1) ~= "/" then
    if not cwd then
      return nil, "Cannot determine terminal shell directory", vim.log.levels.WARN
    end
    path = vim.fs.joinpath(cwd, path)
    if vim.fn.isdirectory(path) == 0 and vim.fn.filereadable(path) == 0 then
      for parent in vim.fs.parents(cwd) do
        local candidate = vim.fs.joinpath(parent, reference.path)
        if vim.fn.isdirectory(candidate) == 1 or vim.fn.filereadable(candidate) == 1 then
          path = candidate
          break
        end
      end
    end
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
