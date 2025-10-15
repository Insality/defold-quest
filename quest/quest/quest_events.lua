local queue = require("event.queue")

local M = {}

---Quest event types
---@alias quest.event_type "register"|"start"|"progress"|"task_completed"|"completed"

---Quest event data structure
---@class quest.event_data
---@field quest_config quest.config Quest configuration
---@field delta number|nil Progress delta (for "progress" type)
---@field total number|nil Total progress (for "progress" type)
---@field task_index number|nil Task index (for "progress" and "task_completed" types)

---Single queue for all quest events in proper order: register -> start -> progress -> task_completed -> completed
---@class quest.queue.quest_event: queue
---@field subscribe fun(_, callback: fun(event_type: quest.event_type, quest_id: string, event_data: quest.event_data): boolean?, _)
M.on_quest_event = queue.create()

return M
