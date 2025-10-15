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


---Converts table to one-line string
---@param t table
---@param depth number?
---@param result string|nil Internal parameter
---@return string, boolean result String representation of table, Is max string length reached
function M.table_to_string(t, depth, result)
	if not t then
		return "", false
	end

	depth = depth or 0
	result = result or "{"

	for key, value in pairs(t) do
		if #result > 1 then
			result = result .. ", "
		end

		if type(value) == "table" then
			if depth == 0 then
				local table_len = 0
				for _ in pairs(value) do
					table_len = table_len + 1
				end
				result = result .. key .. ": {... #" .. table_len .. "}"
			else
				local convert_result, is_limit = M.table_to_string(value, depth - 1, "")
				result = result .. key .. ": {" .. convert_result
				if is_limit then
					break
				end
			end
		else
			result = result .. key .. ": " .. tostring(value)
		end
	end

	return result .. "}", false
end


return M

