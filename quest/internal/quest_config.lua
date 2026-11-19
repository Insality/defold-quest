local utils = require("quest.internal.quest_utils")
local logger = require("quest.internal.quest_logger")

---Contains a quest config required to describe a quest
---@class quest.config: table
---@field tasks quest.task[] List of tasks to complete
---@field required_quests string[]|string|nil List of required quests or single required quest
---@field category string|nil Used for filtering quests
---@field events_offline boolean|nil If true, the quest events will be stored and processed even quest is not active
---@field autostart boolean|nil If true, the quest will be started automatically after all requirements are met
---@field autofinish boolean|nil If true, the quest will be finished automatically after all tasks are completed
---@field repeatable boolean|nil If true, the quest will be not stored in the completed list
---@field use_max_task_value boolean|nil If true, the maximum value of the task is used instead of the sum of all quest events

---Describes a task for the quest
---@class quest.task
---@field action string Action to perform to complete the task. Example: "destroy" or "collect"
---@field object string|nil Object to specify the task, example: "enemy" or "money"
---@field required number|nil Required amount of the object to complete the task. Example: 100. Default: 1
---@field initial number|nil Initial amount of the object. Example: 0

local M = {}


---Quests Data
---@type table<string, quest.config>
local QUESTS_DATA = {}


---Add quests to existing configuration from file or table. Quests with the same id are replaced.
---@param config_or_path string|table<string, quest.config> Quest config or path to the config file
---@return boolean True if success
function M.add_quests(config_or_path)
	if type(config_or_path) == "string" then
		local config = utils.load_json(config_or_path)
		if not config then
			logger:error("Can't load quest config", config_or_path)
			return false
		end

		config_or_path = config
	end

	for quest_id, quest_config in pairs(config_or_path) do
		QUESTS_DATA[quest_id] = quest_config
	end

	return true
end


---Remove quests from existing configuration
---@param quest_ids string[] Quest ids to remove
function M.remove_quests(quest_ids)
	for index = 1, #quest_ids do
		QUESTS_DATA[quest_ids[index]] = nil
	end
end


---Remove all quests from configuration
function M.reset_state()
	QUESTS_DATA = {}
end


---Get quest config by id
---@param quest_id string Quest id
---@return quest.config
function M.get_quest_config(quest_id)
	return QUESTS_DATA[quest_id]
end


---Get quests data
---@return table<string, quest.config>
function M.get_quests_data()
	return QUESTS_DATA
end


---Get total quests count in quests config
---@return number Total quests count
function M.get_quests_count()
	local count = 0
	for _ in pairs(QUESTS_DATA) do
		count = count + 1
	end

	return count
end


return M

