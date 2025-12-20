local utils = require("quest.internal.quest_utils")
local state = require("quest.internal.quest_state")
local config = require("quest.internal.quest_config")

local M = {}


---Check if all quests in the list are completed
---@param quests_list string[]|string|nil Quests list or single quest
---@return boolean
function M.is_all_quests_completed(quests_list)
	if not quests_list then
		return true
	end

	local quests = state.get_state()

	-- Handle single string case
	if type(quests_list) == "string" then
		return utils.contains(quests.completed, quests_list)
	end

	-- Handle array case
	for i = 1, #quests_list do
		if not utils.contains(quests.completed, quests_list[i]) then
			return false
		end
	end

	return true
end


---Check if quest is completed
---@param quest_id string
---@return boolean is_completed Quest completed state
function M.is_completed(quest_id)
	local quests = state.get_state()
	return utils.contains(quests.completed, quest_id) --[[@as boolean]]
end


---Check quest is active
---@return boolean Quest active state
function M.is_active(quest_id)
	local quests = state.get_state()
	local quest = quests.current[quest_id]
	return quest and quest.is_active
end


---All requirements is satisfied for start quest
---@param quest_id string Quest id
---@return boolean
function M.is_available(quest_id)
	local quest_config = config.get_quest_config(quest_id)

	return not M.is_completed(quest_id) and M.is_all_quests_completed(quest_config.required_quests)
end


---Quests can be not started, but catch all progress events.
---So quest can be completed, when it will be started with a already completed required quests.
---@param quest_id string Quest id
---@return boolean
function M.is_catch_offline(quest_id)
	local not_completed = not M.is_completed(quest_id)
	local catch_offline = config.get_quests_data()[quest_id].events_offline
	return (not_completed and catch_offline) and true or false
end


---Check if all tasks of quest are completed
---@param quest_id string Quest id to check
---@return boolean True if all tasks are completed
function M.is_tasks_completed(quest_id)
	local quest_config = config.get_quest_config(quest_id)
	if not quest_config then
		return false
	end

	local quests = state.get_state().current[quest_id]
	if not quests then
		return false
	end

	for i = 1, #quest_config.tasks do
		local required = quest_config.tasks[i].required or 1
		local current = quests.progress[i] or 0

		if current < required then
			return false
		end
	end

	return true
end


---Check if quest can be started
---@param quest_id string Quest id to check
---@return boolean is_can_be_started True if quest can be started
function M.can_be_started_quest(quest_id)
	local quest_config = config.get_quest_config(quest_id)

	local is_completed = M.is_completed(quest_id)
	local is_active = M.is_active(quest_id)
	local quests_ok = M.is_all_quests_completed(quest_config.required_quests)
	return not is_completed and not is_active and quests_ok
end


return M

