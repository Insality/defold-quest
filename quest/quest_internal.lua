local M = {}

---Describes a quest progress data, used to save quest progress
---@class quest.progress
---@field progress number[] Quest progress
---@field is_active boolean Is quest started to earn quest events
---@field start_time number Quest start time in seconds since epoch

---Contains a quest config required to describe a quest
---@class quest.config
---@field tasks quest.task[] List of tasks to complete
---@field required_quests string[]|string|nil List of required quests or single required quest
---@field category string|nil Used for filtering quests
---@field events_offline boolean|nil If true, the quest events will be stored and processed even quest is not active
---@field autostart boolean|nil If true, the quest will be started automatically after all requirements are met
---@field autofinish boolean|nil If true, the quest will be finished automatically after all tasks are completed
---@field repeatable boolean|nil If true, the quest will be not stored in the completed list
---@field use_max_task_value boolean|nil If true, the maximum value of the task is used instead of the sum of all quest events

---@class quest.tokens
---@field tokens table<string, number>

---Describes a task for the quest
---@class quest.task
---@field action string Action to perform to complete the task. Example: "destroy" or "collect"
---@field object string|nil Object to specify the task, example: "enemy" or "money"
---@field required number|nil Required amount of the object to complete the task. Example: 100. Default: 1
---@field initial number|nil Initial amount of the object. Example: 0

---@class quest.logger
---@field trace fun(logger: quest.logger, message: string, data: any|nil)
---@field debug fun(logger: quest.logger, message: string, data: any|nil)
---@field info fun(logger: quest.logger, message: string, data: any|nil)
---@field warn fun(logger: quest.logger, message: string, data: any|nil)
---@field error fun(logger: quest.logger, message: string, data: any|nil)

---Quests Data
---@type table<string, quest.config>
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


---Load quest config from file or table
---@param config_or_path string|table<string, quest.config> Quest config or path to the config file
---@return boolean True if success
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
