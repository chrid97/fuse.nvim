local M = {}
local ns = vim.api.nvim_create_namespace("timer")

function M.setup()
	M.user_commands()
end

local function open_floating_window()
	local buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
	vim.api.nvim_set_option_value("buflisted", false, { buf = buf })

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
	local inactivity_timer_ms = 10000

	local remaining_ms = duration_ms
	local inactivity_remaining = inactivity_timer_ms
	local tick_ms = 50
	local buf, win = nil, nil

	local group = vim.api.nvim_create_augroup("RopeTimerInactivity", { clear = true })
	vim.api.nvim_create_autocmd("TextChangedI", {
		group = group,
		callback = function()
			inactivity_remaining = inactivity_timer_ms
			if win and vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
			win, buf = nil, nil
		end,
	})

	local timer = vim.uv.new_timer()
	if not timer then
		return
	end
	timer:start(
		0,
		tick_ms,
		vim.schedule_wrap(function()
			if inactivity_remaining > 0 then
				inactivity_remaining = inactivity_remaining - tick_ms
				return
			end

			if not (win and vim.api.nvim_win_is_valid(win)) then
				buf, win = open_floating_window()
			end

			remaining_ms = remaining_ms - tick_ms

			if remaining_ms <= 0 then
				if win and vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
				win, buf = nil, nil
				-- vim.on_key(nil, ns)
				timer:stop()
				timer:close()
				return
			end

			local rope_length = math.floor(vim.o.columns * remaining_ms / duration_ms)
			if rope_length < 0 then
				rope_length = 0
			end
			draw_rope(buf, rope_length)
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
