local utils = require("quest.internal.quest_utils")
local state = require("quest.internal.quest_state")
local config = require("quest.internal.quest_config")
local logger = require("quest.internal.quest_logger")
local quest_events = require("quest.internal.quest_events")

local M = {}


---Apply event to quest
---@param quest_id string Quest id to apply event
---@param quest_progress quest.progress Quest progress
---@param action string Event action
---@param object string|nil Event object
---@param amount number|nil Event amount
---@return boolean is_updated True if quest was updated
function M.apply_event(quest_id, quest_progress, action, object, amount)
	object = object or ""
	amount = amount or 1

	local quest_config = config.get_quest_config(quest_id)
	if not quest_config then
		return false
	end

	local is_updated = false

	for task_index = 1, #quest_config.tasks do
		local task_data = quest_config.tasks[task_index]
		local required = task_data.required or 1
		local match_action = task_data.action == action
		local match_object = (task_data.object == object or task_data.object == "" or task_data.object == nil)

		if match_action and match_object then
			is_updated = true

			local prev_value = quest_progress.progress[task_index] or 0
			local task_value
			if quest_config.use_max_task_value then
				task_value = math.max(prev_value, amount)
			else
				task_value = prev_value + amount
			end

			quest_progress.progress[task_index] = utils.clamp(task_value, 0, required)
			local delta = quest_progress.progress[task_index] - prev_value
			quest_events.progress(quest_id, quest_config, delta, quest_progress.progress[task_index], task_index)

			logger:debug("Quest progress updated", {
				quest_id = quest_id,
				task_index = task_index,
				delta = delta,
				total = quest_progress.progress[task_index]
			})

			if quest_progress.progress[task_index] == required then
				quest_events.task_completed(quest_id, quest_config, task_index)

				logger:debug("Quest task completed", {
					quest_id = quest_id,
					task_index = task_index
				})
			end
		end
	end

	return is_updated
end


---Process event for all current quests
---@param action string Event action
---@param object string|nil Event object
---@param amount number|nil Event amount default 1
---@param is_can_event_callback quest.event.is_can_event|nil Callback to check if event can be processed
---@return boolean is_applied True if event was applied to at least one quest
function M.process_event(action, object, amount, is_can_event_callback)
	local quests_data = config.get_quests_data()
	local current = state.get_state().current
	local is_applied = false

	for quest_id, quest in pairs(current) do
		local quest_config = quests_data[quest_id]
		local is_can_event = true
		if is_can_event_callback then
			local result = is_can_event_callback:trigger(quest_id, quest_config)
			is_can_event = result or false
		end

		if is_can_event then
			if M.apply_event(quest_id, quest, action, object, amount) then
				is_applied = true
			end
		end
	end

	logger:debug("Quest event process", {
		action = action,
		object = object ~= "" and object or nil,
		amount = amount,
		is_applied = is_applied
	})

	return is_applied
end


return M

