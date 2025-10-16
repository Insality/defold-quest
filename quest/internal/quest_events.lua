local queue = require("event.queue")

local M = {}

---Quest event types
---@alias quest.event_type "register"|"start"|"progress"|"task_completed"|"completed"

---Quest event data structure
---@class quest.event_data
---@field type quest.event_type
---@field quest_id string
---@field quest_config quest.config Quest configuration
---@field delta number|nil Progress delta (for "progress" type)
---@field total number|nil Total progress (for "progress" type)
---@field task_index number|nil Task index (for "progress" and "task_completed" types)

---Single queue for all quest events in proper order: register -> start -> progress -> task_completed -> completed
---@class quest.queue.quest_event: queue
---@field subscribe fun(_, callback: fun(event_data: quest.event_data):boolean?, context: any): boolean?, _)
M.on_quest_event = queue.create()


---Register quest event
---@param quest_id string
---@param quest_config quest.config
function M.register(quest_id, quest_config)
	M.on_quest_event:push({
		type = "register",
		quest_id = quest_id,
		quest_config = quest_config
	})
end


---Start quest event
---@param quest_id string
---@param quest_config quest.config
function M.start(quest_id, quest_config)
	M.on_quest_event:push({
		type = "start",
		quest_id = quest_id,
		quest_config = quest_config
	})
end



---Progress quest event
---@param quest_id string
---@param quest_config quest.config
---@param delta number
---@param total number
---@param task_index number
function M.progress(quest_id, quest_config, delta, total, task_index)
	M.on_quest_event:push({
		type = "progress",
		quest_id = quest_id,
		quest_config = quest_config,
		delta = delta,
		total = total,
		task_index = task_index
	})
end


---Task completed quest event
---@param quest_id string
---@param quest_config quest.config
---@param task_index number
function M.task_completed(quest_id, quest_config, task_index)
	M.on_quest_event:push({
		type = "task_completed",
		quest_id = quest_id,
		quest_config = quest_config,
		task_index = task_index
	})
end


---Completed quest event
---@param quest_id string
---@param quest_config quest.config
function M.completed(quest_id, quest_config)
	M.on_quest_event:push({
		type = "completed",
		quest_id = quest_id,
		quest_config = quest_config
	})
end


return M
