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
		-- Clear llist of old issues from previous format
		vim.fn.setloclist(0, {})
		vim.cmd("lclose")

		local new_lines = vim.fn.split(output, "\n")
		-- TODO we should probably do a compare to what we have to not change the
		-- buffer if we don't have to
		api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
	else
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
			vim.fn.setloclist(0, { { bufnr = 0, lnum = locations[1], col = locations[2], text = errors } })
			vim.cmd("lopen")
		end
	end

	fn.delete(error_file)
end

-- TODO add in a range format option

return M
