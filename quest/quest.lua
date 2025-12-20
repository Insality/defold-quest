---The Defold Quest module.
---Use this module to track tasks in your game.
---You can add, start, complete and track quests progress.
---
---# Quest Status Lifecycle
---
---Quests go through different states during their lifecycle:
---
---## Quest States:
---* **not_started**: Quest exists in config but hasn't been registered yet
---* **registered**: Quest is registered and can receive events (if events_offline = true)
---* **active**: Quest is started and actively earning progress from events
---* **completed**: Quest has finished all tasks and is marked as completed
---
---## Quest Types:
---* **autostart**: Quest automatically starts when requirements are met
---* **autofinish**: Quest automatically completes when all tasks are done
---* **repeatable**: Quest can be started again after completion (not stored in completed list)
---* **events_offline**: Quest can receive events even when not active
---
---## Quest Status Meanings:
---* **can_be_started**: Quest meets all requirements and is ready to start
---* **active**: Quest is currently running and earning progress
---* **completed**: Quest has finished and cannot be restarted (unless repeatable)
---
---# Usage Example:
---```lua
---quest.init(require("game.quests"))
---quest.event("kill", "enemy") -- Apply kill enemy event
---local active = quest.get_current() -- Get all active quests
---```

local logger = require("quest.internal.quest_logger")
local state = require("quest.internal.quest_state")
local config = require("quest.internal.quest_config")
local validation = require("quest.internal.quest_validation")
local lifecycle = require("quest.internal.quest_lifecycle")
local quest_progress = require("quest.internal.quest_progress")
local quest_events = require("quest.internal.quest_events")
local utils = require("quest.internal.quest_utils")

---@class quest
local M = {}

M.on_quest_event = quest_events.on_quest_event
M.is_can_start = quest_events.is_can_start
M.is_can_complete = quest_events.is_can_complete
M.is_can_event = quest_events.is_can_event


-- Save and load state, before init
---Set state (for saving/loading)
---@param external_state quest.state
function M.set_state(external_state)
	state.set_state(external_state)
end


---Get state (for saving/loading)
---@return quest.state
function M.get_state()
	return state.get_state()
end


-- Initialize quest system
---Initialize quest system with config and start processing quests
---		quest.init()
---		quest.init(require("game.quests"))
---		quest.init("/resources/quests.json")
---@param quest_config_or_path table<string, quest.config>|string|nil Path to quest config or config table. Can be nil to init without quests.
function M.init(quest_config_or_path)
	if quest_config_or_path then
		M.add_quests(quest_config_or_path)
	end

	lifecycle.register_offline_quests()
	M.update_quests()

	logger:info("Quest system initialized", {
		total_quests = M.get_quests_count(),
		active_quests = utils.count_table_entries(M.get_current()),
		completed_quests = #state.get_state().completed,
		can_be_started = utils.count_table_entries(M.get_can_be_started())
	})
end


---Add quests to the system from config file or table
---		quest.add_quests(require("game.quests"))
---		quest.add_quests("/resources/quests.json")
---@param quest_config_or_path table<string, quest.config>|string Lua table or path to quest config. Example: "/resources/quests.json"
function M.add_quests(quest_config_or_path)
	config.load_config(quest_config_or_path)
	M.postprocess_quest_state()

	lifecycle.set_quest_relative_map(lifecycle.make_relative_quests_map())
	lifecycle.create_can_be_started_list()
	lifecycle.register_offline_quests()
	M.update_quests()
end


-- Trigger quest event
---Main function to apply event to all current quests. Call it when specific quest action is performed.
---		quest.event("game_started")
---		quest.event("kill", "enemy")
---		quest.event("kill", "enemy", 2)
---		quest.event("collect", "coin", 3)
---@param action string Event action
---@param object string|nil Event object
---@param amount number|nil Event amount default 1
function M.event(action, object, amount)
	local is_can_event_callback = nil
	if not M.is_can_event:is_empty() then
		is_can_event_callback = M.is_can_event
	end

	local is_applied = quest_progress.process_event(action, object, amount, is_can_event_callback)

	if is_applied then
		M.update_quests()
	end
end


---Add progress to task
---@param quest_id string Quest id
---@param task_index number Task index
---@param amount number Amount to add
function M.add_task_progress(quest_id, task_index, amount)
	local quests = state.get_state()
	local quest_progress_data = quests.current[quest_id]
	if not quest_progress_data then
		return
	end

	local quest_config = config.get_quest_config(quest_id)
	if not quest_config or not quest_config.tasks[task_index] then
		return
	end

	local task_config = quest_config.tasks[task_index]
	local action = task_config.action
	local object = task_config.object
	local is_applied = quest_progress.apply_event(quest_id, quest_progress_data, action, object, amount)
	if is_applied then
		M.update_quests()
	end

	logger:debug("Quest task progress added", {
		quest_id = quest_id,
		task_index = task_index,
		action = action,
		object = object,
		amount = amount,
		is_applied = is_applied
	})
end


-- Check quest status
---Check quest is active
---@param quest_id string
---@return boolean Quest active state
function M.is_active(quest_id)
	return validation.is_active(quest_id)
end


---Check quest is completed
---@param quest_id string
---@return boolean is_completed Quest completed state
function M.is_completed(quest_id)
	return validation.is_completed(quest_id)
end


---Check quest is can be started now
---@param quest_id string
---@return boolean Quest can start state
function M.is_can_start_quest(quest_id)
	local quest_config = config.get_quest_config(quest_id)
	if not quest_config then
		return false
	end

	local is_can_start_extra = true
	if not quest_events.is_can_start:is_empty() then
		is_can_start_extra = M.is_can_start:trigger(quest_id, quest_config)
	end

	return is_can_start_extra and validation.is_available(quest_id) and not validation.is_active(quest_id)
end


---Check quest is can be completed now
---@param quest_id string
---@return boolean Quest can complete state
function M.is_can_complete_quest(quest_id)
	local quest_config = config.get_quest_config(quest_id)

	local is_can_complete_extra = true
	if not M.is_can_complete:is_empty() then
		is_can_complete_extra = M.is_can_complete:trigger(quest_id, quest_config)
	end

	return is_can_complete_extra and validation.is_active(quest_id) and validation.is_tasks_completed(quest_id)
end


---Get current progress on quest tasks.
---Returns an array-like table with task progress values.
---		local progress = quest.get_progress("kill_enemies")
---		print(progress[1]) -- Progress on first task
---		print(progress[2]) -- Progress on second task
---		--
---		local progress = quest.get_progress("nonexistent_quest")
---		print(#progress) -- Will be 0 for non-existent quests
---@param quest_id string Quest identifier
---@return table<number, number> progress List of task progress, ex {0, 2, 0}
function M.get_progress(quest_id)
	local quests = state.get_state()
	return quests.current[quest_id] and quests.current[quest_id].progress or {}
end


---Get task progress by task index
---@param quest_id string
---@param task_index number
---@return number
function M.get_task_progress(quest_id, task_index)
	local quests = state.get_state()
	-- Get in current or completed list
	local is_completed = validation.is_completed(quest_id)
	if is_completed then
		local quest_config = config.get_quest_config(quest_id)
		if quest_config and quest_config.tasks[task_index] then
			return quest_config.tasks[task_index].required or 1
		end
		return 0
	end

	if not quests.current[quest_id] then
		return 0
	end

	return quests.current[quest_id].progress[task_index] or 0
end


-- Manage quests
---Start quest, if it can be started
---@param quest_id string
---@return boolean Quest started state
function M.start_quest(quest_id)
	if M.is_can_start_quest(quest_id) then
		lifecycle.start_quest(quest_id)
		M.update_quests()
		return true
	end

	return false
end


---Complete quest, if it can be completed
---@param quest_id string Quest id
function M.complete_quest(quest_id)
	if M.is_can_complete_quest(quest_id) then
		lifecycle.finish_quest(quest_id)
		M.update_quests()
	end
end


---Force complete quest, without checking conditions
---@param quest_id string Quest id
function M.force_complete_quest(quest_id)
	lifecycle.finish_quest(quest_id)
	M.update_quests()
end


---Reset quest progress
---@param quest_id string Quest id
function M.reset_progress(quest_id)
	local quests = state.get_state()
	local quest = quests.current[quest_id]

	if quest then
		for i = 1, #quest.progress do
			quest.progress[i] = 0
		end
	end

	M.update_quests()

	logger:debug("Quest progress reset", quest_id)
end


---Reset quest, remove from current and completed lists, and update can be started list
---@param quest_id string Quest id
function M.reset_quest(quest_id)
	local quests = state.get_state()
	quests.current[quest_id] = nil

	for index = 1, #quests.completed do
		if quests.completed[index] == quest_id then
			table.remove(quests.completed, index)
		end
	end

	lifecycle.create_can_be_started_list()
	lifecycle.register_offline_quests()
	M.update_quests()

	logger:debug("Quest reset", quest_id)
end


---Clear all quest progress
function M.clear_all_progress()
	local quests = state.get_state()
	quests.current = {}
	quests.completed = {}

	lifecycle.create_can_be_started_list()
	lifecycle.register_offline_quests()
	M.update_quests()
end


-- Get quests
---Get current active quests
---@param category string|nil
---@return table<string, quest.progress>
function M.get_current(category)
	local quests = state.get_state().current
	local result = {}

	for quest_id, quest in pairs(quests) do
		local is_category_match = true
		if category then
			local quest_config = config.get_quest_config(quest_id)
			is_category_match = quest_config and quest_config.category == category
		end

		if quest.is_active and is_category_match then
			result[quest_id] = quest
		end
	end

	return result
end


---Get completed quests map
---@param category string|nil Optional category filter
---@return table<string, boolean> Map of completed quests
function M.get_completed(category)
	local quests = state.get_state()

	if not category then
		local result = {}
		for index = 1, #quests.completed do
			result[quests.completed[index]] = true
		end
		return result
	end

	local result = {}
	local quests_data = config.get_quests_data()

	for index = 1, #quests.completed do
		local quest_id = quests.completed[index]
		local quest_config = quests_data[quest_id]
		if quest_config and quest_config.category == category then
			result[quest_id] = true
		end
	end

	return result
end


---Get quests that can be started
---@param category string|nil Optional category filter
---@return table<string, boolean>
function M.get_can_be_started(category)
	local quests = lifecycle.get_can_be_started()

	if not category then
		return quests
	end

	local result = {}
	for quest_id, _ in pairs(quests) do
		local quest_config = config.get_quest_config(quest_id)
		if quest_config and quest_config.category == category then
			result[quest_id] = true
		end
	end

	return result
end


---Get quest config by id
---@param quest_id string Quest id
---@return quest.config
function M.get_quest_config(quest_id)
	return config.get_quest_config(quest_id)
end


---Get current quests that have tasks matching the specified action and object.
---Returns an array of quest IDs that contain matching tasks.
---		local quests = quest.is_current_with_task("kill", "enemy")
---		if #quests > 0 then
---			print("Found " .. #quests .. " quests with kill enemy task")
---		end
---		--
---		local quests = quest.is_current_with_task("collect")
---		for i, quest_id in ipairs(quests) do
---			print("Quest " .. quest_id .. " has collect task")
---		end
---@param action string Action to check (e.g., "kill", "collect")
---@param object string|nil Object to check (e.g., "enemy", "coin"). Can be nil for any object
---@return string[] List of quest IDs that have matching tasks
function M.get_current_with_task(action, object)
	local quests = state.get_state().current
	local result = {}

	for quest_id, quest in pairs(quests) do
		local quest_config = config.get_quest_config(quest_id)
		if quest_config then
			for i = 1, #quest_config.tasks do
				local task = quest_config.tasks[i]
				local match_object = true
				if object ~= nil then
					match_object = (task.object == object or task.object == "" or task.object == nil)
				end

				if task.action == action and match_object then
					table.insert(result, quest_id)
					break -- Found a match, no need to check other tasks for this quest
				end
			end
		end
	end

	return result
end


-- System
---Customize the logging mechanism used by Quest Module. You can use **Defold Log** library or provide a custom logger.
---@param logger_instance quest.logger|table|nil
function M.set_logger(logger_instance)
	logger.set_logger(logger_instance)
end


---Reset Module quest state, probably you want to use it only in case of soft game reload
function M.reset_state()
	state.reset_state()
	lifecycle.reset_runtime_state()
	quest_events.reset_state()
end


---Get quests data
---@return table<string, quest.config>
function M.get_quests_data()
	return config.get_quests_data()
end


---Get total quests count in quests config
---@return number Total quests count
function M.get_quests_count()
	return config.get_quests_count()
end


---Update quests lifecycle by processing autostart and autofinish quests.
---This function recursively processes quest state changes until no more changes occur.
---It handles quest completion and starting based on quest configuration and validation.
---
---Process:
---1. Complete autofinish quests that meet completion criteria
---2. Start autostart quests that meet start criteria
---3. Recursively call itself if any changes occurred
---@private
function M.update_quests()
	local should_continue = false

	-- Complete autofinish quests with validation
	local current = state.get_state().current
	local quests_data = config.get_quests_data()
	for quest_id, quest in pairs(current) do
		if quest.is_active and quests_data[quest_id].autofinish then
			if M.is_can_complete_quest(quest_id) then
				lifecycle.finish_quest(quest_id)
				should_continue = true
			end
		end
	end

	-- Start autostart quests with validation
	local can_be_started = lifecycle.get_can_be_started()
	for quest_id, _ in pairs(can_be_started) do
		local quest = quests_data[quest_id]
		if quest.autostart then
			if M.is_can_start_quest(quest_id) then
				lifecycle.start_quest(quest_id)
				should_continue = true
			end
		end
	end

	-- Keep updating until no more changes
	if should_continue then
		M.update_quests()
	end
end


---Postprocess quest state to ensure all task progress entries exist
---@private
function M.postprocess_quest_state()
	local current = state.get_state().current
	for quest_id, quest in pairs(current) do
		local quest_config = config.get_quest_config(quest_id)
		if quest_config then
			for i = 1, #quest_config.tasks do
				quest.progress[i] = quest.progress[i] or 0
			end
		end
	end
end


return M
