local api = vim.api
local fn = vim.fn

local M = {}

local function buf_get_full_text(bufnr)
	local text = table.concat(api.nvim_buf_get_lines(bufnr, 0, -1, true), "\n")
	if api.nvim_buf_get_option(bufnr, "eol") then
		text = text .. "\n"
	end
	return text
end

M.format_file = function()
	local flags
	local error_file = fn.tempname()
	local config_file = fn.findfile("stylua.toml", ".;")

	if fn.empty(config_file) == 0 then
		flags = "--config-path " .. config_file
	else
		flags = ""
	end

	local stylua_command = string.format("stylua %s - 2> %s", flags, error_file)

	local output = fn.system(stylua_command, buf_get_full_text(0))

	if fn.empty(output) == 0 then
		local new_lines = vim.fn.split(output, "\n")
		api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
	else
		local errors = table.concat(vim.fn.readfile(error_file), " ")
		-- TODO parse the errors better here. it looks like we actually get
		-- a range in this string. We may be able to parse this out and put it
		-- in the quickfix list
		print(errors)
	end

	fn.delete(error_file)
end

-- TODO add in a range format option

return M
