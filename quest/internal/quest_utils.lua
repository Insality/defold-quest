local M = {}


---Check if table contains value
---@param t table
---@param value any
---@return boolean
function M.contains(t, value)
	for index = 1, #t do
		if t[index] == value then
			return true
		end
	end

	return false
end


---Clamp value between min and max
---@param value number
---@param min number
---@param max number
---@return number
function M.clamp(value, min, max)
	if min and max and min > max then
		min, max = max, min
	end
	return math.min(max or value, math.max(min or value, value))
end


---Load JSON file from game resources folder (by relative path to game.project)
---Return nil if file not found or error
---@param json_path string
---@return table|nil
function M.load_json(json_path)
	local resource, is_error = sys.load_resource(json_path)
	if is_error or not resource then
		return nil
	end

	return json.decode(resource)
end


---Count entries in a table
---@param t table
---@return number
function M.count_table_entries(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end


return M

