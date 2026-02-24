local M = {}
local ns = vim.api.nvim_create_namespace("timer")

local inactivity_timer_ms = 10000

-- local group = vim.api.nvim_create_augroup("RopeTimer", { clear = true })
--
-- vim.api.nvim_create_autocmd("InsertCharPre", {
-- 	group = group,
-- 	callback = function()
-- 		vim.schedule()
-- 	end,
-- })

function M.setup()
	M.user_commands()
end

local function open_floating_window()
	-- vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
	-- vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
	-- vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		row = 0,
		col = 0,
		width = vim.o.columns,
		height = 1,
		focusable = false,
		style = "minimal",
		noautocmd = true,
	})

	return buf, win
end

local function draw_rope(buf, rope_length)
	local rope = string.rep("█", rope_length)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { rope })
end

local function start_timer()
	local duration_ms = 30000
	local tick_ms = 50
	local remaining_ms = duration_ms

	local buf, win = open_floating_window()

	local timer = vim.uv.new_timer()
	if not timer then
		return
	end
	timer:start(
		0,
		tick_ms,
		vim.schedule_wrap(function()
			if remaining_ms < 0 then
				if win and vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
				vim.on_key(nil, ns)
				timer:stop()
				timer:close()
				return
			end

			local rope_length = math.ceil(vim.o.columns * remaining_ms / duration_ms)
			draw_rope(buf, rope_length)

			remaining_ms = remaining_ms - tick_ms
		end)
	)
end

function M.user_commands()
	vim.api.nvim_create_user_command("StartTimer", start_timer, {})

	vim.api.nvim_create_user_command("ReloadRopeTimer", function()
		require("lazy.core.loader").reload("nvim-rope-timer")
	end, {})
end

return M
