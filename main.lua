local start = os.time()
local duration = 10

while true do
  local elapsed_time = os.time() - start
  local remaining = duration - elapsed_time

  if remaining <= 0 then
    print("Times up")
    break
  end

  print(remaining .. " remaining")
end
