local api = vim.api
local fn = vim.fn

local M = {}

local state = {
  had_format_err = false,
}

local config = {
  error_display_strategy = "loclist",
}

local function buf_get_full_text(bufnr)
  local text = table.concat(api.nvim_buf_get_lines(bufnr, 0, -1, true), "\n")
  if api.nvim_buf_get_option(bufnr, "eol") then
    text = text .. "\n"
  end
  return text
end

local function create_flags()
  local config_file = fn.findfile("stylua.toml", ".;")
  if fn.empty(config_file) == 0 then
    return "--config-path " .. config_file
  else
    return ""
  end
end

local function no_errors(output, input)
  if output ~= input then
    local new_lines = vim.fn.split(output, "\n")
    api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
  end
  -- We try a little bit to make sure we aren't closing a loclist that we didn't create.
  -- This isn't perfect in the case of long sessions, but probably better than nothing.
  if config.error_display_strategy == "loclist" and state.had_format_err then
    vim.fn.setloclist(0, {})
    vim.cmd("lclose")
  end
end

local function handle_errors(error_file)
  local errors = table.concat(vim.fn.readfile(error_file), " ")

  -- A little hacky, but we know that the error messsages are always shaped
  -- in a similiar way containing:
  --(starting from line 32, character 2 and ending on line 32, character 5)
  -- So we know that:
  --	- locations[1] = start line
  --	- locations[2] = start col
  --	- locations[3] = end line
  --	- locations[4] = end col
  local locations = {}
  for num in errors:gmatch("%d+") do
    table.insert(locations, num)
  end

  -- Ensure that we have the full range
  if table.getn(locations) == 4 then
    if config.error_display_strategy == "loclist" then
      vim.fn.setloclist(0, { { bufnr = 0, lnum = locations[1], col = locations[2], text = errors } })
      vim.cmd("lopen")
    end
    state.had_format_err = true
  end
end

M.format_file = function(user_config)
  if user_config and user_config.error_display_strategy then
    config.error_display_strategy = user_config.error_display_strategy
  end
  local error_file = fn.tempname()
  local flags = create_flags()

  local stylua_command = string.format("stylua %s - 2> %s", flags, error_file)

  local input = buf_get_full_text(0)
  local output = fn.system(stylua_command, input)

  if fn.empty(output) == 0 then
    no_errors(output, input)
  else
    handle_errors(error_file)
  end

  fn.delete(error_file)
end

-- TODO add in a range format option

return M
