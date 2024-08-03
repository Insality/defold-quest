local event = require("event.event")
local quest_internal = require("quest.quest_internal")

local M = {}

-- Module bindings --

---@class quest.event.quest_register: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest)
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest), _)
M.on_quest_register = event.create()

---@class quest.event.quest_start: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest)
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest), _)
M.on_quest_start = event.create()

---@class quest.event.quest_end: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest)
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest), _)
M.on_quest_completed = event.create()

---@class quest.event.quest_progress: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest, delta: number, total: number, task_index: number)
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest, delta: number, total: number, task_index: number), _)
M.on_quest_progress = event.create()

---@class quest.event.quest_task_complete: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest, task_index: number)
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest, task_index: number), _)
M.on_quest_task_completed = event.create()

---@class quest.event.is_can_start: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest): boolean
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest): boolean, _)
M.is_can_start = event.create()

---@class quest.event.is_can_complete: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest): boolean
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest): boolean, _)
M.is_can_complete = event.create()

---@class quest.event.is_can_event: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest): boolean
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest): boolean, _)
M.is_can_event = event.create()



---Persist data between game sessions
---@type quest.state
M.state = nil

---@type quest.runtime_state
M.runtime = nil

function M.reset_state()
	M.state = {
		current = {},
		completed = {}
	}

	M.runtime = {
		is_started = false,
		can_be_started = {},
		quest_relative_map = nil
	}
end

M.reset_state()


---@param logger_instance quest.logger|nil
function M.set_logger(logger_instance)
	quest_internal.logger = logger_instance or quest_internal.empty_logger
end


local function get_quests_state()
	return M.state
end


---Get quests config
---@return table<string, quest.quest>
local function get_quests_data()
	return quest_internal.QUESTS_DATA
end


function M.get_quests_count()
	local count = 0
	for _ in pairs(get_quests_data()) do
		count = count + 1
	end

	return count
end


---Get quest config by id
---@param quest_id string
---@return quest.quest
local function get_quest_config(quest_id)
	return get_quests_data()[quest_id]
end


local function make_relative_quests_map()
	local quests_data = get_quests_data()
	local map = {}

	for quest_id, quest in pairs(quests_data) do
		if quest.required_quests then
			for i = 1, #quest.required_quests do
				map[quest.required_quests[i]] = map[quest.required_quests[i]] or {}
				table.insert(map[quest.required_quests[i]], quest_id)
			end
		end
	end

	return map
end


local function is_quests_ok(quests_list)
	if not quests_list then
		return true
	end

	local quests = get_quests_state()

	local is_ok = true
	for i = 1, #quests_list do
		if not quest_internal.contains(quests.completed, quests_list[i]) then
			is_ok = false
			break
		end
	end

	return is_ok
end


---All requirements is satisfied for start quest
local function is_available(quest_id)
	local quest_config = get_quest_config(quest_id)

	return not M.is_completed(quest_id) and
				is_quests_ok(quest_config.required_quests)
end


local function is_catch_offline(quest_id)
	return not M.is_completed(quest_id) and get_quests_data()[quest_id].events_offline
end


local function is_tasks_completed(quest_id)
	local quest_config = get_quest_config(quest_id)
	local quests = get_quests_state().current[quest_id]

	for i = 1, #quest_config.tasks do
		local required = quest_config.tasks[i].required or 1
		local current = quests.progress[i]

		if current < required then
			return false
		end
	end

	return true
end


local function can_be_started_quest(quest_id)
	local quest_config = get_quest_config(quest_id)

	local is_completed = M.is_completed(quest_id)
	local is_active = M.is_active(quest_id)
	local quests_ok = is_quests_ok(quest_config.required_quests)
	return not is_completed and not is_active and quests_ok
end


local function create_can_be_started_list()
	local quest_config = get_quests_data()

	M.runtime.can_be_started = {}
	local can_be_started = M.runtime.can_be_started

	for quest_id, quest in pairs(quest_config) do
		if can_be_started_quest(quest_id) then
			table.insert(can_be_started, quest_id)
		end
	end
end


local function remove_from_started_list(quest_id)
	local can_be_started = M.runtime.can_be_started

	local index = quest_internal.contains(can_be_started, quest_id)
	if index and type(index) == "number" then
		table.remove(can_be_started, index)
	end
end


local function on_complete_quest_update_started_list(quest_id)
	local can_be_started = M.runtime.can_be_started
	local relative_quests = M.runtime.quest_relative_map

	if not relative_quests then
		return
	end

	if not relative_quests[quest_id] then
		return
	end

	for i = 1, #relative_quests[quest_id] do
		local q = relative_quests[quest_id][i]
		if can_be_started_quest(q) and not quest_internal.contains(can_be_started) then
			table.insert(can_be_started, q)
		end
	end

	-- Update repeatable quests
	if can_be_started_quest(quest_id) and not quest_internal.contains(can_be_started) then
		table.insert(can_be_started, quest_id)
	end
end


---Register quest to catch events even it not started
local function register_quest(quest_id)
	local quests = get_quests_state()
	local quest_config = get_quest_config(quest_id)
	if quests.current[quest_id] then
		quest_internal.logger:warn("Quest already started", quest_id)
		return
	end

	---@type quest.quest_progress
	local quest_progress = {
		progress = {},
		is_active = false,
		start_time = socket.gettime()
	}

	quests.current[quest_id] = quest_progress
	for i = 1, #quest_config.tasks do
		quests.current[quest_id].progress[i] = 0
	end

	M.on_quest_register:trigger(quest_id, quest_config)

	quest_internal.logger:debug("Quest registered", quest_id)
end


local function clean_unexisting_quests()
	local current = get_quests_state().current
	for quest_id, quest in pairs(current) do
		local quest_config = get_quest_config(quest_id)
		if not quest_config then
			current[quest_id] = nil
		end
	end
end


local function migrate_quests_data()
	local current = get_quests_state().current
	for quest_id, quest in pairs(current) do
		local quest_config = get_quest_config(quest_id)
		for i = 1, #quest_config.tasks do
			quest.progress[i] = quest.progress[i] or 0
		end
	end
end


---Start quest
---@param quest_id string
local function start_quest(quest_id)
	local quest_config = get_quest_config(quest_id)
	local quests = get_quests_state()
	if not quests.current[quest_id] then
		register_quest(quest_id)
	end

	quests.current[quest_id].is_active = true
	remove_from_started_list(quest_id)

	M.on_quest_start:trigger(quest_id, quest_config)

	quest_internal.logger:debug("Quest started", quest_id)

	if quest_config.autofinish then
		M.complete_quest(quest_id)
	end
end


local function finish_quest(quest_id)
	local quests = get_quests_state()
	local quest_config = get_quest_config(quest_id)

	if not quests.current[quest_id] then
		quest_internal.logger:warn("No quest in current list to end it", quest_id)
		return
	end

	if M.is_completed(quest_id) then
		quest_internal.logger:warn("Quest already completed", quest_id)
		return
	end

	quests.current[quest_id] = nil
	if not quest_config.repeatable then
		table.insert(quests.completed, quest_id)
	end

	M.on_quest_completed:trigger(quest_id, quest_config)
	quest_internal.logger:debug("Quest completed", quest_id)

	on_complete_quest_update_started_list(quest_id)
	M.update_quests()
end


local function register_offline_quests()
	local quests_data = get_quests_data()
	local quests = get_quests_state()

	for quest_id, quest in pairs(quests_data) do
		if is_catch_offline(quest_id) and not quests.current[quest_id] then
			register_quest(quest_id)
		end
	end
end


local function update_quests_list()
	local quests_data = get_quests_data()

	local current = get_quests_state().current
	for quest_id, quest in pairs(current) do
		if quest.is_active and quests_data[quest_id].autofinish then
			M.complete_quest(quest_id)
		end
	end

	local can_be_started = M.runtime.can_be_started
	for i = #can_be_started, 1, -1 do
		local quest_id = can_be_started[i]
		local quest = quests_data[quest_id]

		if quest.autostart then
			M.start_quest(quest_id)
		end
	end
end


---Apply event to quest
---@param quest_id string
---@param quest quest.quest_progress
---@param action string
---@param object string|nil
---@param amount number|nil
local function apply_event(quest_id, quest, action, object, amount)
	object = object or ""
	amount = amount or 1

	local quest_config = get_quest_config(quest_id)
	local is_updated = false

	for task_index = 1, #quest_config.tasks do
		local task_data = quest_config.tasks[task_index]
		local required = task_data.required or 1
		local match_action = task_data.action == action
		local match_object = (task_data.object == object or task_data.object == "")

		if match_action and match_object then
			is_updated = true

			local prev_value = quest.progress[task_index]
			local task_value
			if quest_config.use_max_task_value then
				task_value = math.max(prev_value, amount)
			else
				task_value = prev_value + amount
			end

			quest.progress[task_index] = quest_internal.clamp(task_value, 0, required)
			local delta = quest.progress[task_index] - prev_value

			M.on_quest_progress:trigger(quest_id, quest_config, delta, quest.progress[task_index], task_index)

			quest_internal.logger:debug("Quest progress updated", {
				quest_id = quest_id,
				task_index = task_index,
				delta = delta,
				total = quest.progress[task_index]
			})

			if quest.progress[task_index] == required then
				M.on_quest_task_completed:trigger(quest_id, quest_config, task_index)

				quest_internal.logger:debug("Quest task completed", {
					quest_id = quest_id,
					task_index = task_index
				})
			end
		end
	end

	return is_updated
end


---Get current progress on quest
---@param quest_id string
---@return table<string, number>
function M.get_progress(quest_id)
	local quests = get_quests_state()
	return quests.current[quest_id] and quests.current[quest_id].progress or {}
end


---Get current active quests
---@param category string|nil
---@return table<string, quest.quest_progress>
function M.get_current(category)
	local quests = get_quests_state().current
	local result = {}

	for quest_id, quest in pairs(quests) do
		local is_category_match = true
		if category then
			local quest_config = get_quest_config(quest_id)
			is_category_match = quest_config.category == category
		end

		if quest.is_active and is_category_match then
			result[quest_id] = quest
		end
	end

	return result
end


---Get completed quests map
---@return table<string, boolean> Map of completed quests
function M.get_completed()
	-- TODO add category filter
	return get_quests_state().completed
end


---Check if there is quests in current with
---pointer action and object
---@param action string
---@param object string|nil
---@return boolean
function M.is_current_with_task(action, object)
	local quests = get_quests_state().current
	for quest_id, quest in pairs(quests) do
		local quest_config = get_quest_config(quest_id)
		for i = 1, #quest_config.tasks do
			local task = quest_config.tasks[i]
			if task.action == action and (task.object == object or task.object == "") then
				return true
			end
		end
	end

	return false
end


---Check quest is active
---@return boolean Quest active state
function M.is_active(quest_id)
	local quests = get_quests_state()
	local quest = quests.current[quest_id]
	return quest and quest.is_active
end


---Check quest is completed
---@param quest_id string
---@return boolean Quest completed state
function M.is_completed(quest_id)
	local quests = get_quests_state()
	return quest_internal.contains(quests.completed, quest_id) --[[@as boolean]]
end


---Check quest is can be started now
---@param quest_id string
---@return boolean Quest can start state
function M.is_can_start_quest(quest_id)
	local quest_config = get_quest_config(quest_id)
	if not quest_config then
		return false
	end

	local is_can_start_extra = true
	if not M.is_can_start:is_empty() then
		is_can_start_extra = M.is_can_start:trigger(quest_id, quest_config)
	end

	return is_can_start_extra and is_available(quest_id) and not M.is_active(quest_id)
end


---Start quest, if it can be started
---@param quest_id string
---@return boolean Quest started state
function M.start_quest(quest_id)
	if M.is_can_start_quest(quest_id) then
		start_quest(quest_id)
		return true
	end

	return false
end


---Check quest is can be completed now
---@param quest_id string
---@return boolean Quest can complete state
function M.is_can_complete_quest(quest_id)
	local quest_config = get_quest_config(quest_id)

	local is_can_complete_extra = true
	if not M.is_can_complete:is_empty() then
		is_can_complete_extra = M.is_can_complete:trigger(quest_id, quest_config)
	end

	return is_can_complete_extra and M.is_active(quest_id) and is_tasks_completed(quest_id)
end


---Complete quest, if it can be completed
---@param quest_id string Quest id
function M.complete_quest(quest_id)
	if M.is_can_complete_quest(quest_id) then
		finish_quest(quest_id)
	end
end


---Force complete quest
---@param quest_id string Quest id
function M.force_complete_quest(quest_id)
	finish_quest(quest_id)
end


---Reset quets progress, only on current quests
---@param quest_id string Quest id
function M.reset_progress(quest_id)
	local quests = get_quests_state()
	local quest = quests.current[quest_id]

	if quest then
		for i = 1, #quest.progress do
			quest.progress[i] = 0
		end
	end

	M.update_quests()

	quest_internal.logger:debug("Quest progress reset", quest_id)
end


---Get quest config by id
---@param quest_id string Quest id
---@return quest.quest
function M.get_quest_config(quest_id)
	return get_quest_config(quest_id)
end


---Apply event to all current quests
---@param action string Event action
---@param object string|nil Event object
---@param amount number|nil Event amount
function M.quest_event(action, object, amount)
	local quests_data = get_quests_data()
	local current = get_quests_state().current
	local is_applied = false

	for quest_id, quest in pairs(current) do
		local quest_config = quests_data[quest_id]
		local is_can_event = true
		if not M.is_can_event:is_empty() then
			is_can_event = M.is_can_event:trigger(quest_id, quest_config)
		end

		if is_can_event then
			if apply_event(quest_id, quest, action, object, amount) then
				is_applied = true
			end
		end
	end

	if is_applied then
		M.update_quests()
	end

	quest_internal.logger:debug("Quest event process", {
		action = action,
		object = object,
		amount = amount,
		is_applied = is_applied
	})
end


---Init quest system
---@param quest_config_or_path table|string Path to quest config. Example: "/resources/quests.json"
function M.init(quest_config_or_path)
	quest_internal.load_config(quest_config_or_path)

	clean_unexisting_quests()
	migrate_quests_data()

	M.runtime.is_started = true
	M.runtime.quest_relative_map = make_relative_quests_map()

	create_can_be_started_list()
	register_offline_quests()
	M.update_quests()

	quest_internal.logger:info("Quest system initialized", { quest_count = M.get_quests_count() })
end


---Update quests list
-- It will start and end quests, by checking quests condition
function M.update_quests()
	if not M.runtime.is_started then
		return
	end

	update_quests_list()
end


return M
