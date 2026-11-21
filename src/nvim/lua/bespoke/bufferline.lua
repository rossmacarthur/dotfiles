local M = {}

function M.focus(step)
  vim.cmd.stopinsert()
  if vim.bo.buftype == "terminal" then
    local tab = vim.api.nvim_get_current_tabpage()
    vim.schedule(function()
      if vim.api.nvim_get_current_tabpage() ~= tab then
        return
      end
      vim.api.nvim_set_current_win(require("bespoke.editor").ensure_window())
      M.focus(step)
    end)
    return
  end

  -- Refresh the focused buffer before stepping, including after leaving a terminal
  require("cokeline.buffers").get_visible()
  require("cokeline.mappings").by_step("focus", step)
end

function M.delete()
  local buffer = require("cokeline.buffers").get_current()
  if buffer then
    buffer:delete()
  end
end

function M.save_close()
  local buffer = require("cokeline.buffers").get_current()
  if not buffer then
    return
  end
  vim.cmd.write()
  buffer:delete()
  require("bespoke.terminal").focus_visible()
end

function M.setup()
  vim.api.nvim_create_user_command("BespokeBufferDelete", M.delete, {})
  vim.api.nvim_create_user_command("BespokeBufferSaveClose", M.save_close, {})

  local is_picking_focus = require("cokeline.mappings").is_picking_focus

  -- Returns the group highlight suffixed with "Focused" if focused
  local function hl(buffer, group)
    return group .. (buffer.is_focused and "Focused" or "")
  end

  -- Returns the default group highlight
  local function default_hl(buffer)
    return hl(buffer, "CokelineBuffer")
  end

  -- Returns true if the buffer is just after the focused one
  local function is_after_focused(buffer)
    local current = require("cokeline.buffers").get_current()
    return current ~= nil and current.index > 0 and buffer.index == current.index + 1
  end

  local function on_click(_, _, button, _, buffer)
    if button == "l" then
      require("bespoke.editor").open_buffer(buffer.number)
    elseif button == "r" then
      local config = require("cokeline.config").buffers
      if config.delete_on_right_click then
        require("cokeline.utils").buf_delete(buffer.number, config.focus_on_delete)
      end
    end
  end

  local sep = {
    text = "🮇",
    highlight = function(buffer)
      if is_after_focused(buffer) then
        return "CokelineSeparatorAfterFocused"
      end
      if buffer.is_focused then
        return "CokelineSeparatorFocused"
      end
      return buffer.is_first and "CokelineSeparatorFirst" or "CokelineSeparator"
    end,
  }

  local icon = {
    text = function(buffer)
      if is_picking_focus() then
        return " " .. buffer.pick_letter .. " "
      end
      return " " .. buffer.devicon.icon
    end,
    fg = function(buffer)
      return is_picking_focus() and "CokelinePick" or buffer.devicon.color
    end,
  }

  local prefix = {
    text = function(buffer)
      return buffer.unique_prefix
    end,
    highlight = function(buffer)
      return hl(buffer, "CokelinePrefix")
    end,
  }

  local filename = {
    text = function(buffer)
      return buffer.filename
    end,
    highlight = default_hl,
  }

  local close = {
    text = function(buffer)
      local icon = buffer.is_modified and " ⦁" or " ✕"
      return icon .. (buffer.is_last and " " or "")
    end,
    highlight = function(buffer)
      if buffer.is_hovered then
        return hl(buffer, "CokelineCloseHover")
      end
      return hl(buffer, buffer.is_modified and "CokelineModified" or "CokelineClose")
    end,
    on_click = function(_, _, _, _, buffer)
      buffer:delete()
    end,
  }

  local tab_number = {
    text = function(tab)
      if #vim.api.nvim_list_tabpages() <= 1 then
        return ""
      end
      return " " .. tab.index .. " "
    end,
    highlight = function(tab)
      return tab.is_active and "CokelineTabActive" or "CokelineTab"
    end,
  }

  local components = { sep, icon, prefix, filename, close }
  for _, component in ipairs(components) do
    component.on_click = component.on_click or on_click
  end

  require("cokeline").setup({
    fill_hl = "CokelineFill",
    default_hl = { fg = default_hl, bg = default_hl },
    components = components,
    tabs = { components = { tab_number } },
  })
end

return M
