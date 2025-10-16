---Persist data between game sessions
---@class quest.state
---@field current table<string, quest.progress> quest_id -> quest.progress
---@field completed string[]

---Describes a quest progress data, used to save quest progress
---@class quest.progress
---@field progress number[] Quest progress
---@field is_active boolean Is quest started to earn quest events
---@field start_time number Quest start time in seconds since epoch

local M = {}


---@type quest.state
local state = {
	current = {},
	completed = {}
}


---Reset Module quest state, probably you want to use it only in case of soft game reload
function M.reset_state()
	state.current = {}
	state.completed = {}
end


---Get quests state
---@return quest.state
function M.get_state()
	return state
end


---Set external state (for loading saved state)
---@param external_state quest.state
function M.set_state(external_state)
	state = external_state
end


-- Initialize state
M.reset_state()


return M

