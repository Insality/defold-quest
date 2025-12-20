---@type table<string, quest.config>
local QUEST_DATA = {
	["quest_collect_1"] = {
		autostart = true,
		autofinish = true,
		tasks = {
			{ action = "get", object = "money", required = 10 },
			{ action = "get", object = "exp", required = 100 }
		}
	},
	["quest_destroy_1"] = {
		autostart = true,
		autofinish = true,
		tasks = {
			{ action = "destroy", object = "stone", required = 100 }
		}
	}
}


return function()
	describe("Defold Quest - Core Functionality", function()
		local quest ---@type quest

		before(function()
			quest = require("quest.quest")
			quest.reset_state()
			-- Clear queue from previous tests
			quest.on_quest_event:clear()
		end)

		after(function()
		end)

		it("Should initialize and start quests", function()
			quest.init(QUEST_DATA)
			assert(quest.get_current()["quest_collect_1"])
			assert(quest.get_current()["quest_destroy_1"])
		end)

		it("Should track quest progress", function()
			quest.init(QUEST_DATA)

			quest.event("get", "money", 5)
			local progress = quest.get_task_progress("quest_collect_1", 1)
			assert(progress == 5)

			quest.event("get", "money", 3)
			progress = quest.get_task_progress("quest_collect_1", 1)
			assert(progress == 8)
		end)

		it("Should complete tasks when required amount reached", function()
			quest.init(QUEST_DATA)

			quest.event("get", "money", 10)
			local progress = quest.get_task_progress("quest_collect_1", 1)
			assert(progress == 10)

			-- Quest shouldn't complete until all tasks done
			assert(quest.is_active("quest_collect_1"))
		end)

		it("Should complete quest when all tasks done", function()
			quest.init(QUEST_DATA)

			quest.event("get", "money", 10)
			quest.event("get", "exp", 100)

			assert(quest.is_completed("quest_collect_1"))
			assert(not quest.is_active("quest_collect_1"))
		end)

		it("Should get progress for quest", function()
			quest.init(QUEST_DATA)

			quest.event("get", "money", 5)
			quest.event("get", "exp", 50)

			local progress = quest.get_progress("quest_collect_1")
			assert(progress[1] == 5)
			assert(progress[2] == 50)
		end)

		it("Should get completed quests", function()
			quest.init(QUEST_DATA)

			quest.event("destroy", "stone", 100)

			local completed = quest.get_completed()
			assert(completed["quest_destroy_1"])
		end)

		it("Should get current active quests", function()
			quest.init(QUEST_DATA)

			local current = quest.get_current()
			assert(current["quest_collect_1"])
			assert(current["quest_destroy_1"])

			quest.event("destroy", "stone", 100)

			current = quest.get_current()
			assert(current["quest_collect_1"])
			assert(not current["quest_destroy_1"])
		end)

		it("Should check if quest is active", function()
			quest.init(QUEST_DATA)

			assert(quest.is_active("quest_collect_1"))

			quest.event("get", "money", 10)
			quest.event("get", "exp", 100)

			assert(not quest.is_active("quest_collect_1"))
		end)

		it("Should check if quest is completed", function()
			quest.init(QUEST_DATA)

			assert(not quest.is_completed("quest_collect_1"))

			quest.event("get", "money", 10)
			quest.event("get", "exp", 100)

			assert(quest.is_completed("quest_collect_1"))
		end)

		it("Should reset quest progress", function()
			quest.init(QUEST_DATA)

			quest.event("get", "money", 5)
			assert(quest.get_task_progress("quest_collect_1", 1) == 5)

			quest.reset_progress("quest_collect_1")
			assert(quest.get_task_progress("quest_collect_1", 1) == 0)
		end)

		it("Should add task progress manually", function()
			quest.init(QUEST_DATA)

			quest.add_task_progress("quest_collect_1", 1, 7)
			assert(quest.get_task_progress("quest_collect_1", 1) == 7)
		end)

		it("Should get quest config", function()
			quest.init(QUEST_DATA)

			local config = quest.get_quest_config("quest_collect_1")
			assert(config ~= nil)
			assert(#config.tasks == 2)
		end)

		it("Should count quests", function()
			quest.init(QUEST_DATA)
			assert(quest.get_quests_count() == 2)
		end)
	end)
end
