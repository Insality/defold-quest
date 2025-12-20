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
---@param v1 number
---@param v2 number
---@return number
function M.clamp(value, v1, v2)
	v1 = v1 or -math.huge
	v2 = v2 or math.huge
	if v1 > v2 then
		v1, v2 = v2, v1
	end

	return math.max(v1, math.min(value, v2))
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

