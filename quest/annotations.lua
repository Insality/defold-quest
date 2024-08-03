
---Persisted data
---@class quest.state
---@field current table<string, quest.quest_progress>
---@field completed table<string, boolean>

---Runtime data
---@class quest.runtime_state
---@field is_started boolean
---@field can_be_started table<string, boolean>
---@field quest_relative_map table<string, string[]>|nil

---@class quest.quest_progress
---@field progress number[] @Quest progress
---@field is_active boolean @Is quest started to earn quest events
---@field start_time number @Quest start time in seconds since epoch

---@class quest.quest
---@field tasks quest.task[] @List of tasks to complete
---@field required_quests string|string[]|nil @List of required quests
---@field category string|nil @Used for filtering quests
---@field events_offline boolean|nil @If true, the quest events will be stored and processed even quest is not active
---@field autostart boolean|nil @If true, the quest will be started automatically after all requirements are met
---@field autofinish boolean|nil @If true, the quest will be finished automatically after all tasks are completed
---@field repeatable boolean|nil @If true, the quest will be not stored in the completed list
---@field use_max_task_value boolean|nil @If true, the maximum value of the task is used instead of the sum of all quest events

---@class quest.tokens
---@field tokens table<string, number>

---@class quest.task
---@field action string
---@field object string|nil
---@field required number|nil @Default 1
---@field initial number|nil @Default 0
---@field param1 string|nil
---@field param2 string|nil

---@class quest.logger
---@field trace fun(logger: quest.logger, message: string, data: any|nil)
---@field debug fun(logger: quest.logger, message: string, data: any|nil)
---@field info fun(logger: quest.logger, message: string, data: any|nil)
---@field warn fun(logger: quest.logger, message: string, data: any|nil)
---@field error fun(logger: quest.logger, message: string, data: any|nil)
