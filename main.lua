local start = os.time()
local duration = 10

local rope_length = 10
local remaining_rope = 10
while true do
	local elapsed_time = os.time() - start
	local remaining = duration - elapsed_time

	if remaining <= 10 then
		local rope = ""
		for i = remaining_rope, 0, -1 do
			rope = rope .. "="
		end
		for i = 0, rope_length - remaining_rope, 1 do
			rope = rope .. " "
		end
		print("[" .. rope .. "]")
		remaining_rope = remaining_rope - 1
		-- print(remaining .. " remaining")
		-- os.execute("sleep 1")
	end

	if remaining <= 0 then
		print("Times up")
		break
	end
end
