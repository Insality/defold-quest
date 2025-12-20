local state = require("quest.internal.quest_state")
local config = require("quest.internal.quest_config")
local validation = require("quest.internal.quest_validation")
local logger = require("quest.internal.quest_logger")
local quest_events = require("quest.internal.quest_events")

local M = {}


-- Runtime state variables (not saved to disk)
local can_be_started = {}
local quest_relative_map = nil


---Get can be started list
---@return table<string, boolean>
function M.get_can_be_started()
	return can_be_started
end


---Set quest relative map
---@param map table<string, string[]>|nil
function M.set_quest_relative_map(map)
	quest_relative_map = map
end


---Register quest to catch events even it not started
---@param quest_id string
function M.register_quest(quest_id)
	local quests = state.get_state()
	local quest_config = config.get_quest_config(quest_id)
	if quests.current[quest_id] then
		logger:warn("Quest already started", quest_id)
		return
	end

	---@type quest.progress
	local quest_progress = {
		progress = {},
		is_active = false,
		start_time = 0  -- Will be set when quest starts
	}

	quests.current[quest_id] = quest_progress
	for i = 1, #quest_config.tasks do
		quests.current[quest_id].progress[i] = 0
	end

	quest_events.register(quest_id, quest_config)
	logger:debug("Quest registered", quest_id)
end


---Remove quest from can be started list
---@param quest_id string Quest id
function M.remove_from_started_list(quest_id)
	if not can_be_started then
		logger:debug("Quest is already not in can be started list", quest_id)
		return
	end

	can_be_started[quest_id] = nil
end


---Start quest
---@param quest_id string
---@return boolean is_started Quest started state
function M.start_quest(quest_id)
	local quest_config = config.get_quest_config(quest_id)
	local quests = state.get_state()
	if not quests.current[quest_id] then
		M.register_quest(quest_id)
	end

	if quests.current[quest_id].is_active then
		logger:warn("Quest already started", quest_id)
		return false
	end

	quests.current[quest_id].is_active = true
	quests.current[quest_id].start_time = socket.gettime()
	M.remove_from_started_list(quest_id)
	quest_events.start(quest_id, quest_config)
	logger:debug("Quest started", quest_id)

	return true
end


---Finish quest
---@param quest_id string
function M.finish_quest(quest_id)
	local quests = state.get_state()
	local quest_config = config.get_quest_config(quest_id)

	if not quests.current[quest_id] then
		logger:warn("No quest in current list to end it", quest_id)
		return
	end

	if validation.is_completed(quest_id) then
		logger:warn("Quest already completed", quest_id)
		return
	end

	quests.current[quest_id] = nil
	if not quest_config.repeatable then
		table.insert(quests.completed, quest_id)
	end

	quest_events.completed(quest_id, quest_config)
	logger:debug("Quest completed", quest_id)

	M.update_can_be_started_list_on_complete(quest_id)
end


---Make relative quests map
---@return table<string, string[]> quests_table Relative quests map
function M.make_relative_quests_map()
	local quests_data = config.get_quests_data()
	local map = {}

	for quest_id, quest in pairs(quests_data) do
		if quest.required_quests then
			-- Handle single string case
			if type(quest.required_quests) == "string" then
				map[quest.required_quests] = map[quest.required_quests] or {}
				table.insert(map[quest.required_quests], quest_id)
			else
				-- Handle array case
				for i = 1, #quest.required_quests do
					map[quest.required_quests[i]] = map[quest.required_quests[i]] or {}
					table.insert(map[quest.required_quests[i]], quest_id)
				end
			end
		end
	end

	return map
end


---Create can be started list
function M.create_can_be_started_list()
	local quest_configs = config.get_quests_data()

	can_be_started = {}

	for quest_id, quest in pairs(quest_configs) do
		if validation.can_be_started_quest(quest_id) then
			can_be_started[quest_id] = true
		end
	end
end


---Update can be started list after quest completion
---@param quest_id string Quest id
function M.update_can_be_started_list_on_complete(quest_id)
	if not quest_relative_map or not quest_relative_map[quest_id] then
		return
	end

	for i = 1, #quest_relative_map[quest_id] do
		local q = quest_relative_map[quest_id][i]
		if validation.can_be_started_quest(q) and not can_be_started[q] then
			can_be_started[q] = true
		end
	end

	-- Update repeatable quests
	if validation.can_be_started_quest(quest_id) and not can_be_started[quest_id] then
		can_be_started[quest_id] = true
	end
end


---Register offline quests that can catch events
function M.register_offline_quests()
	local quests_data = config.get_quests_data()
	local quests = state.get_state()

	for quest_id, quest in pairs(quests_data) do
		if validation.is_catch_offline(quest_id) and not quests.current[quest_id] then
			M.register_quest(quest_id)
		end
	end
end


---Reset runtime state variables
function M.reset_runtime_state()
	can_be_started = {}
	quest_relative_map = nil
end


return M
