---@type table<string, quest.config>
local QUEST_DATA = {
	["quest_collect_1"] = {
		autostart = true,
		autofinish = true,
		tasks = {
			{ action = "get", object = "money", required = 10 },
			{ action = "get", object = "exp", required = 100 }
		}
	}
}


return function()
	describe("Defold Quest - Event Queue", function()
		local quest = {}

		before(function()
			quest = require("quest.quest")
			quest.reset_state()
			-- Clear queue from previous tests
			quest.on_quest_event:clear()
		end)

		after(function()
		end)

		it("Should emit register and start events", function()
			local events = {}

			-- Subscribe BEFORE init so we can catch events as they happen
			quest.on_quest_event:subscribe(function(event_data)
				table.insert(events, {
					type = event_data.type,
					quest_id = event_data.quest_id
				})
				return true  -- Mark event as handled
			end)

			quest.init(QUEST_DATA)

			-- Check we got register and start events
			assert(#events >= 2, "Expected at least 2 events, got " .. #events)
			assert(events[1].type == "register", "Expected first event to be 'register', got '" .. events[1].type .. "'")
			assert(events[1].quest_id == "quest_collect_1", "Expected first quest_id to be 'quest_collect_1', got '" .. events[1].quest_id .. "'")
			assert(events[2].type == "start", "Expected second event to be 'start', got '" .. events[2].type .. "'")
			assert(events[2].quest_id == "quest_collect_1", "Expected second quest_id to be 'quest_collect_1', got '" .. events[2].quest_id .. "'")
		end)

		it("Should emit progress events", function()
			local progress_events = {}

			-- Subscribe BEFORE init
			quest.on_quest_event:subscribe(function(event_data)
				if event_data.type == "progress" then
					table.insert(progress_events, {
						quest_id = event_data.quest_id,
						task_index = event_data.task_index,
						delta = event_data.delta,
						total = event_data.total
					})
				end
				return true  -- Mark event as handled
			end)

			quest.init(QUEST_DATA)
			quest.event("get", "money", 5)

			assert(#progress_events == 1)
			assert(progress_events[1].quest_id == "quest_collect_1")
			assert(progress_events[1].task_index == 1)
			assert(progress_events[1].delta == 5)
			assert(progress_events[1].total == 5)
		end)

		it("Should emit task_completed events", function()
			local task_completed_events = {}

			-- Subscribe BEFORE init
			quest.on_quest_event:subscribe(function(event_data)
				if event_data.type == "task_completed" then
					table.insert(task_completed_events, {
						quest_id = event_data.quest_id,
						task_index = event_data.task_index
					})
				end
				return true  -- Mark event as handled
			end)

			quest.init(QUEST_DATA)
			quest.event("get", "money", 10)

			assert(#task_completed_events == 1)
			assert(task_completed_events[1].quest_id == "quest_collect_1")
			assert(task_completed_events[1].task_index == 1)
		end)

		it("Should emit completed events", function()
			local completed_events = {}

			-- Subscribe BEFORE init
			quest.on_quest_event:subscribe(function(event_data)
				if event_data.type == "completed" then
					table.insert(completed_events, {
						quest_id = event_data.quest_id
					})
				end
				return true  -- Mark event as handled
			end)

			quest.init(QUEST_DATA)
			quest.event("get", "money", 10)
			quest.event("get", "exp", 100)

			assert(#completed_events == 1)
			assert(completed_events[1].quest_id == "quest_collect_1")
		end)

		it("Should maintain event order", function()
			local events = {}

			-- Subscribe BEFORE init to capture all events
			quest.on_quest_event:subscribe(function(event_data)
				table.insert(events, event_data.type)
				return true  -- Mark event as handled
			end)

			quest.init(QUEST_DATA)
			quest.event("get", "money", 10)
			quest.event("get", "exp", 100)

			-- Expected order: register -> start -> progress -> task_completed -> progress -> task_completed -> completed
			assert(events[1] == "register")
			assert(events[2] == "start")
			assert(events[3] == "progress")
			assert(events[4] == "task_completed")
			assert(events[5] == "progress")
			assert(events[6] == "task_completed")
			assert(events[7] == "completed")
		end)

		it("Should handle multiple quest events", function()
			local quest_data = {
				["quest_1"] = {
					autostart = true,
					autofinish = true,
					tasks = {
						{ action = "get", object = "gold", required = 5 }
					}
				},
				["quest_2"] = {
					autostart = true,
					autofinish = true,
					tasks = {
						{ action = "get", object = "silver", required = 3 }
					}
				}
			}

			local events_by_quest = {}

			-- Subscribe BEFORE init
			quest.on_quest_event:subscribe(function(event_data)
				if not events_by_quest[event_data.quest_id] then
					events_by_quest[event_data.quest_id] = {}
				end
				table.insert(events_by_quest[event_data.quest_id], event_data.type)
				return true  -- Mark event as handled
			end)

			quest.init(quest_data)
			quest.event("get", "gold", 5)
			quest.event("get", "silver", 3)

			-- Check both quests got their events in order
			assert(#events_by_quest["quest_1"] >= 4) -- register, start, progress, task_completed, completed
			assert(#events_by_quest["quest_2"] >= 4)
		end)

		it("Should include quest_config in events", function()
			-- Subscribe BEFORE init
			quest.on_quest_event:subscribe(function(event_data)
				assert(event_data.quest_config ~= nil)
				assert(event_data.quest_config.tasks ~= nil)
				return true  -- Mark event as handled
			end)

			quest.init(QUEST_DATA)
		end)
	end)
end

