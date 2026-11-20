local M = {}
local repositories = {}

function M.is_dirty(status)
  local repo = repositories[status.gitdir]
  return repo and repo.dirty == true or false
end

local function refresh(repo, redraw)
  repo.refresh_requested = true
  if repo.pending then
    return
  end
  repo.pending = true

  -- Batch editor/Gitsigns events, with at most one Git process per worktree.
  vim.defer_fn(function()
    repo.refresh_requested = false
    vim.system(
      {
        "git",
        "--no-optional-locks",
        "--git-dir=" .. repo.gitdir,
        "--work-tree=" .. repo.root,
        "status",
        "--porcelain=v1",
        "-z",
        "--untracked-files=normal",
      },
      { timeout = 10000 },
      vim.schedule_wrap(function(result)
        repo.pending = false
        if result.code == 0 then
          local dirty = result.stdout ~= ""
          if repo.dirty ~= dirty then
            repo.dirty = dirty
            redraw()
          end
        else
          local reason = vim.trim(result.stderr or "")
          if reason == "" then
            reason = "exit " .. result.code
          end
          vim.notify_once("Git status failed for " .. repo.root .. ": " .. reason, vim.log.levels.WARN)
        end
        if repo.refresh_requested then
          refresh(repo, redraw)
        end
      end)
    )
  end, 150)
end

function M.refresh(bufnr, redraw)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local status = vim.b[bufnr].gitsigns_status_dict
  if not status or not status.root or not status.gitdir then
    return
  end

  local repo = repositories[status.gitdir]
  if not repo then
    repo = { root = status.root, gitdir = status.gitdir }
    repositories[status.gitdir] = repo
  end
  refresh(repo, redraw)
end

return M
