local M = {}
local ns = vim.api.nvim_create_namespace("timer")
local buf = vim.api.nvim_create_buf(false, true)
local window_width = vim.o.columns
local duration_ms = 30000
local tick_ms = 50

local inactivity_timer_ms = 10000

local remaining_ms = duration_ms
local remaining_rope = window_width

local burn_rate = remaining_rope / duration_ms
local burn_accumulator = 0.0

function M.setup()
	M.user_commands()
end

-- function BumpTimer()
-- 	remaining_ms = remaining_ms + 10
-- 	remaining_rope = remaining_rope + 10
-- 	burn_accumulator = 0
-- 	UpdateRopeLength(window_width)
-- end

function M.user_commands()
	vim.api.nvim_create_user_command("StartTimer", StartTimer, {})

	vim.api.nvim_create_user_command("ReloadRopeTimer", function()
		require("lazy.core.loader").reload("nvim-rope-timer")
	end, {})
end

function StartTimer()
	-- local group = vim.api.nvim_create_augroup("RopeTimer", { clear = true })
	--
	-- vim.api.nvim_create_autocmd("InsertCharPre", {
	-- 	group = group,
	-- 	callback = function()
	-- 		vim.schedule(BumpTimer)
	-- 	end,
	-- })

	local rope = string.rep("█", window_width)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { rope })
	vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		row = 0,
		col = 0,
		width = window_width,
		height = 1,
		style = "minimal",
	})
	print("Starting timer!")

	local timer = vim.uv.new_timer()
	if not timer then
		return
	end
	timer:start(
		0,
		tick_ms,
		vim.schedule_wrap(function()
			if remaining_ms <= 0 then
				timer:stop()
				timer:close()
				vim.on_key(nil, ns)
				print("Done!")
				return
			end

			burn_accumulator = burn_accumulator + (burn_rate * tick_ms)

			local burn_now = math.floor(burn_accumulator)
			if burn_now > 0 then
				burn_accumulator = burn_accumulator - burn_now
				remaining_rope = remaining_rope - burn_now
				if remaining_rope < 0 then
					remaining_rope = 0
				end
				print(remaining_rope)
				UpdateRopeLength(remaining_rope)
			end

			remaining_ms = remaining_ms - tick_ms
		end)
	)
end

function UpdateRopeLength(rope_length)
	local rope = string.rep("█", rope_length)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { rope })
end

return M
