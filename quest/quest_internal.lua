local M = {}

---Quests Data
---@type table<string, quest.quest>
M.QUESTS_DATA = {}

--- Use empty function to save a bit of memory
local EMPTY_FUNCTION = function(_, message, context) end

---@type quest.logger
M.empty_logger = {
	trace = EMPTY_FUNCTION,
	debug = EMPTY_FUNCTION,
	info = EMPTY_FUNCTION,
	warn = EMPTY_FUNCTION,
	error = EMPTY_FUNCTION,
}


---@type quest.logger
M.logger = {
	trace = function(_, msg) print("TRACE: " .. msg) end,
	debug = function(_, msg, data) pprint("DEBUG: " .. msg, data) end,
	info = function(_, msg, data) pprint("INFO: " .. msg, data) end,
	warn = function(_, msg, data) pprint("WARN: " .. msg, data) end,
	error = function(_, msg, data) pprint("ERROR: " .. msg, data) end,
}

---@type quest.logger
M.logger = M.empty_logger


---Check if table contains value
---@param t table
---@param value any
---@return number|boolean
function M.contains(t, value)
	for index = 1, #t do
		if t[index] == value then
			return index
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
	if value < min then
		return min
	elseif value > max then
		return max
	end

	return value
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


---Load quest config from file or table
---@param config_or_path string|table
---@return boolean @True if success
function M.load_config(config_or_path)
	if type(config_or_path) == "string" then
		local config = M.load_json(config_or_path)
		if not config then
			M.logger:error("Can't load quest config", config_or_path)
			return false
		end

		config_or_path = config
	end

	M.QUESTS_DATA = config_or_path

	return true
end


return M
